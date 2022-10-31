# Bazel Run and Commit

Example showing deterministic install of an apt package in a Docker image using Bazel.

## How to identify sources of non-determinism?

First, obtain two versions of the archive:

```bash
# Build
bazel build //:image_archive

# Save the output
cp bazel-bin/image_archive.tar a.tar

# Clean
rm -rf ./bazel-*
bazel clean

# Build
bazel build //:image_archive

# Save the output
cp bazel-bin/image_archive.tar b.tar

# Clean
rm -rf ./bazel-*
bazel clean
```

Next, compare them with [Container Diff](https://github.com/GoogleContainerTools/container-diff):

```bash
container-diff-linux-amd64 diff -t file -t size a.tar b.tar
```

Examine the output to find the offending files!

```
-----File-----

These entries have been added to a.tar: None

These entries have been deleted from a.tar: None

These entries have been changed between a.tar and b.tar:
FILE                                 SIZE1        SIZE2
/var/log/dpkg.log                    20K          20K
/var/log/apt/term.log                10.9K        10.9K
/var/cache/ldconfig/aux-cache        6.9K         6.9K
/var/log/apt/history.log             2.1K         2.1K
/var/log/alternatives.log            1.1K         1.1K
```

Finally, update the run commands to remove them:

```diff
container_run_and_commit_layer(
  name = "install_git",
  commands = [
    "apt-get update -y",
    "apt-get install -y git=1:2.30.2-1",
    "apt-get clean",
    "rm -rf /var/lib/apt/lists/*",
+    "rm -rf /var/cache/ldconfig/aux-cache",
+    "rm -rf /var/log/alternatives.log",
+    "rm -rf /var/log/apt/term.log",
+    "rm -rf /var/log/apt/history.log",
+    "rm -rf /var/log/dpkg.log",
  ],
  image = "@dotnet_runtime_deps_6_0_10//image",
)
```
