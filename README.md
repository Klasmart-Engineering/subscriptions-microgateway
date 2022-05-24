# Microgateway Template

A starter template to help teams create their own microgateway

## Important notes

The [API Management team](https://calmisland.atlassian.net/wiki/spaces/AM/overview?homepageId=2619113904) have done their best to expose a number of features to support teams in configuring and managing their gateways. This includes having syncing mechanisms that will automatically raise PRs whenever _(centrally managed)_ configuration or plugins are updated.

Please endeavor to review and merge these PRs in as quickly as possible as it will allow us to keep gateway deployments across the company in-sync.

As some of the configuration is [centrally managed](https://github.com/KL-Engineering/central-microgateway-configuration), the team has a number of **protected** files within the file tree _(that will be automatically synced with your repository)_. These protected files will automatically be overwrite anything found in your repository, so please avoid editting them and any naming collisions.

## Creating a new microgateway

1. Create a repository using this one as a template
2. Raise a PR to add your repository name to [microgateways.json](microgateways.json)
3. Let one of the API Management team know that you have a new gateway, so that they can grant access for your repository to use the centrally managed docker images
4. Update `krakend.json` - `$.name` with the name of your microgateway
5. Add any custom plugins you would like to add to the gateway by adding them to the `/plugins` directory as a `git-submodule`
   1. `cd plugins && git submodule add <repository url>`
   2. These will automatically be built into your docker image by the `Dockerfile` provided
6. Most of the build artefacts should work out of the box (eg. `Dockerfile`, github-actions) however please feel free to customize these as you see fit.
   1. Please avoid changing the base images however, as we manage these centrally (`kl-krakend-builder` & `kl-krakend`)
   
## Useful Links

- [KrakenD configuration file](https://www.krakend.io/docs/configuration/structure/)
- [KrakenD flexible configuration file](https://www.krakend.io/docs/configuration/flexible-config/)
- [KrakenD endpoints](https://www.krakend.io/docs/endpoints/creating-endpoints/)
- [KrakenD backends](https://www.krakend.io/docs/backends/overview/)

## Releasing a new version

When you're ready to release a new deployment, please create a github release, and tag it with a [semantic versioning](https://semver.org/) compliant git tag - _this can all be done by through the github website or github api_ please make sure the tag starts with a `v`. We ask this as we will automatically pull that tag through for your image name. 

### Example

If your release is tagged as `v1.0.2`, your image will be tagged as `<repository-name>:1.0.2`. We also tag each image that is built with the branch name _(intended to be used for pull requests/feature development)_. We also support semver tags like `v2.1.7-beta.82` which will result in a tag of `<repository-name>:v2.1.7-beta.82`. If you require additional tags let the API management team know and we can add them.

## Helm

The team has provided a base `values.yaml` file for you to customize specific to your microgateway. Please customize it
as you need. You might also need to create mutliple versions of the file for different environments. If you have any
requirements which the current template doesn't support, please feed this back to the API management team.

### Protected files

| Path                                               | Description                                                                                          |
| -------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `config/settings/shared/common.json`               | this is used to hold central configuration that should be shared across all regions and environments |
| `config/settings/{environment}/{region}/auth.json` | contains configuration related to our Azure B2C token validation                                     |
| `config/templates/jwks-validation-plugin.json`     | contain a template that can be used to easily add Azure B2C validation to your endpoint              |

### Special Files/Directories

| Path                       | Description                                                                                                                                                                                                             |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `config/settings/shared/*` | we will copy the contents of everything within this directory into the build, so regardless of the `REGION` or `ENVIRONMENT`, every file in this directory will be accessible by the final `krakend.json` configuration |
| `plugins/*`                | All plugins should be added as git submodules, we will automatically build and copy over the resulting go-plugins into your deployment                                                                                  |


## Useful docker commands

### Running locally

#### Validation

```sh
docker buildx build -t validate -f Dockerfile.validate . && \
    docker run -e REGION="global" -e ENVIRONMENT="landing-zone" validate
```

#### Run Gateway

```sh
docker buildx build -t gateway  . && \
    docker run -e FC_SETTINGS="/etc/krakend/config/settings/landing-zone/global" \
        -e FC_PARTIALS="/etc/krakend/config/partials" -e FC_TEMPLATES="/etc/krakend/config/templates" \
        -e FC_ENABLE=1 gateway
```
