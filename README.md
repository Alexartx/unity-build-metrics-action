# Unity Build Metrics

Build Unity projects with GameCI and automatically send build size and build time metrics to Build Metrics.

This Action is a thin wrapper around `game-ci/unity-builder@v4`. It standardizes the Build Metrics setup so teams can get CI metrics with one reusable step instead of hand-rolling custom parameters in every workflow.

## Prerequisites

- A Unity project that already has the Build Metrics plugin installed
- A Build Metrics API key stored in `BUILD_METRICS_API_KEY`
- A working Unity license setup for GameCI

For Unity licensing, always verify the current Unity + GameCI activation guidance for your plan before adopting the workflow broadly. Local Unity Hub activation and CI activation are not the same thing.

The Action does **not** install the plugin for you. The plugin is responsible for collecting and uploading metrics during the build.

## Minimal example

```yaml
name: Unity Build

on:
  push:
    branches: [main]
  pull_request:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4
        with:
          lfs: true
          fetch-depth: 0

      - uses: actions/cache@v4
        with:
          path: Library
          key: Library-Android-${{ github.ref }}
          restore-keys: |
            Library-Android-
            Library-

      - name: Build with Unity Build Metrics
        uses: Alexartx/unity-build-metrics-action@v1
        with:
          unity-version: auto
          target-platform: Android
          build-metrics-api-key: ${{ secrets.BUILD_METRICS_API_KEY }}
        env:
          UNITY_LICENSE: ${{ secrets.UNITY_LICENSE }}
          UNITY_EMAIL: ${{ secrets.UNITY_EMAIL }}
          UNITY_PASSWORD: ${{ secrets.UNITY_PASSWORD }}

      - uses: actions/upload-artifact@v4
        with:
          name: Build-Android
          path: build/Android
```

## Inputs

| Input | Required | Default | Description |
| --- | --- | --- | --- |
| `unity-version` | Yes | - | Unity version to use. `auto` reads from `ProjectVersion.txt`. |
| `target-platform` | Yes | - | Unity target platform, for example `Android`, `iOS`, `WebGL`. |
| `build-metrics-api-key` | Yes | - | API key used by the plugin during the build. |
| `project-path` | No | `.` | Path to the Unity project root. |
| `build-method` | No | - | Fully-qualified static build method for custom build flows. |
| `custom-parameters` | No | - | Additional Unity custom parameters. |
| `build-name` | No | - | Optional build name passed to GameCI. |
| `builds-path` | No | `build` | Output root passed to GameCI. |
| `github-token` | No | - | Optional token forwarded to `gitPrivateToken`. |
| `allow-dirty-git` | No | `false` | Allow builds with uncommitted git changes. |

## Outputs

| Output | Description |
| --- | --- |
| `build-version` | `game-ci/unity-builder` `buildVersion` output. |
| `output-path` | Wrapper-derived root output directory, for example `build`. |
| `artifact-path` | Wrapper-derived platform-specific artifact directory, for example `build/Android`. |

## Examples

- [Android build](./examples/android.yml)
- [iOS build](./examples/ios.yml)
- [Custom build method](./examples/custom-build-method.yml)

## Troubleshooting

### Build Metrics data is not appearing

Check:

- the Build Metrics plugin is installed in the Unity project
- `BUILD_METRICS_API_KEY` is valid
- the build actually ran inside Unity, not only a packaging step

This Action passes Build Metrics data both as environment variables and as Unity `customParameters` so the plugin works inside the GameCI container.

### Unity license activation fails

This Action does not manage licensing by itself. Configure your Unity license exactly as recommended by GameCI:

- [GameCI getting started](https://game.ci/docs/github/getting-started)
- [GameCI activation docs](https://game.ci/docs/github/activation/)

If you are using Unity Personal, treat CI activation as something to validate with a real test workflow before standardizing on it across your team.

## Positioning

This Action is intentionally narrow:

- it does build wrapper + Build Metrics wiring
- it does not replace checkout
- it does not replace cache strategy
- it does not own artifact upload
- it does not add PR comments or regression gates yet

## Related links

- [Build Metrics plugin docs](https://github.com/Alexartx/UnityBuildMetrics/tree/main/packages/unity-plugin)
- [GitHub Actions integration guide](https://github.com/Alexartx/UnityBuildMetrics/blob/main/packages/unity-plugin/Documentation~/ci-cd/github-actions.md)
- [Build Metrics site](https://moonlightember.com/products/build-metrics)
