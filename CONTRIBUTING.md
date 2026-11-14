# Contributing

## Workstation

The tools are described in [Workstation](docs/workstation.md).
The images are Windows images only, built with Docker CE on Windows, through the `win` context from WSL.

## Checks

The images are built, run and checked with:

```bash
scripts/test_images.sh
```

One image is checked alone by naming it, for example `scripts/test_images.sh winsamplenet10razorwebapp`.
Each one passes when it reports healthy and its pages answer.

The .NET code is built and tested in CI on every pull request,
with the .NET Framework sample on Windows and the .NET sample on Linux.

## Pipelines

- `ci.yml` builds, tests and scans on every pull request, and never pushes an image.
- `pkg.yml` publishes the images, from `main` only.
- `scan.yml` scans the whole images every week, as described in [Image scanning](docs/image-scanning.md).

The jobs come from [github-workflow-parts](https://github.com/devpro/github-workflow-parts), pinned by commit.
