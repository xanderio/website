+++
title = "Updating GitLab internal flake inputs using Renovate"
date = "2024-03-19"
+++

In order for nix to be able to update a flake input that dosen't point to a
public repository we need to provide it with an access token. Luckily nix
already provides a mechanism for this, the [`access-token`](https://nixos.org/manual/nix/unstable/command-ref/conf-file.html#conf-access-tokens)
option.

At first I tried to use the `CI_JOB_TOKEN` that is created for every GitLab CI
job, but this token is allow to access the API endpoint that nix uses when
updating an inputs (namely the projects endpoints). Then I remembered that
renovate requires a dedicated gitlab user account to perform it's magic and more
important in this case has access to a `PAT`[^PAT]  for this user.
This `PAT` is pass to renovate via the `RENOVATE_TOKEN` CI variable.

To pass this access token to nix running in the renovate sidecar container we
make use of the [`customEnvVariables`](https://docs.renovatebot.com/self-hosted-configuration/#customenvvariables) 
option and secure it from renovate revieling it in it's log file with the 
[`secrets`](https://docs.renovatebot.com/self-hosted-configuration/#secrets) 
mechanism.

## Putting it all together

Place this in your `config.js` in your renovate runner configuration
repository.

```js
  secrets: {
    RENOVATE_TOKEN: process.env.RENOVATE_TOKEN,
  },
  customEnvVariables: {
    NIX_CONFIG: `extra-access-tokens = ${process.env.CI_SERVER_HOST}=PAT:{{ secrets.RENOVATE_TOKEN }} `,
  },
```

<hr>

[^PAT]: Personal Access Token
