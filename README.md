# Bitbucket backup

## What does it do?

* Fetches a list of all teams the user administers
* Fetches a list of all repos, for all teams and user's personal
* Clones/updates all repos locally, for backup purposes

## What does it *not* do?

* Does not delete any repos removed on Bitbucket. This is on purpose.
* Does not backup any other Bitbucket data or metadata, except for the repos themselves.
* Only Git repos are supported.

## Configuration needed

Create an `.env` file with Bitbucket username/password: use an app password with read capabilities,
both for user data and for the repos themselves. See `.env.sample` for details.
