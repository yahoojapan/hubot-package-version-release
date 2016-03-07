# hubot-package-version-release
[![npm version](https://badge.fury.io/js/hubot-package-version-release.svg)](https://badge.fury.io/js/hubot-package-version-release)

publish release on GitHub based package.json

## Dependencies
* [githubot](https://github.com/iangreenleaf/githubot)
* [async](https://github.com/caolan/async)

## Install

```bash
npm install --save hubot-package-version-release
```

add `hubot-package-version-release` to `external-scripts.json`

```
["hubot-package-version-release"]
```

## Usage

```
hubot> hubot publish release user/repository from package.json
```

result

![](https://cloud.githubusercontent.com/assets/10104981/13453445/86fec89c-e093-11e5-946f-20ce651e1ca5.png)

## Configuration

| environment variable     | description                                                    | default                  |
| ---                      | ---                                                            | ---                      |
| HUBOT_GITHUB_TOKEN       | (**require**) GitHub API Token                                 | -                        |
| HUBOT_GITHUB_BASE_BRANCH | (optional) publish target_commitish                            | 'release'                |
| HUBOT_GITHUB_OWNER       | (optional) default owner (org or user). if it is not given.    | -                        |
| HUBOT_GITHUB_RAW         | (optional) GitHub raw url. It is userful for GitHub Enterprise. | 'https://raw.github.com' |
| HUBOT_GITHUB_API         | (optional) GitHub API url. It is userful for GitHub Enterprise. (This is defined in githubot) | 'https://api.github.com' |

## License
This software is released under the MIT License, see [LICENSE][license-file].

[license-file]: ./LICENSE
