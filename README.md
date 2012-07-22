# PivotHub

A simple way to integrate GitHub Issues into Pivotal Tracker

## Installation

1. Clone the repo

  ```shell
  git clone https://github.com/jrostand/pivothub.git
  ```

2. Get an OAuth key from GitHub. Instructions are available [here](https://help.github.com/articles/creating-an-oauth-token-for-command-line-use)

3. Set up your deployment environment. I use [Heroku](http://www.heroku.com) personally (because you get SSL for free), but I've also tested this with [NodeJitsu](http://nodejitsu.com). Note that I highly recommend using SSL for this app as otherwise your credentials will be transmitted in the clear.

  You'll need the following environment variables set:

  * `PIVOTHUB_BASIC_USER` - Your HTTP basic auth username for pulling issues into Pivotal Tracker
  * `PIVOTHUB_BASIC_PASS` - HTTP basic auth password
  * `GITHUB_TOKEN` - The OAuth token from GitHub
  * `SECRET_TOKEN` - The web hook auth token for closing finished issues (you make this one up)

4. Deploy it!

## Setting up Pivotal Tracker

This section will tell you how to set up Pivotal Tracker to pull in GitHub Issues and (optionally) close Issues that are associated with Finished stories.

### Assumptions

* Your application is deployed at `https://myghissues.herokuapp.com`
* Your GitHub project is at `https://github.com/myaccount/repo`

### Pulling Issues into Pivotal

1. Select `Project` and then `Configure Integrations`

2. Scroll down to `External Tool Integrations` and select `Other` from the options in the `Create New Integration...` box

3. Fill in the form with this information:
    * **Name:** Whatever you'd like to call the Issues panel (e.g., GitHub Issues)
    * **Basic Auth Username:** The value of `PIVOTHUB_BASIC_USER`
    * **Basic Auth Password:** The value of `PIVOTHUB_BASIC_PASS`
    * **Base URL:** `https://github.com/`
    * **Import API URL:** `https://myghissues.herokuapp.com/issues/myaccount/repo`

4. Click `Create`

### Closing Issues from Finished stories

If you would like PivotHub to close Issues that are associated with Finished stories, here's how to set that up:

1. In Pivotal, go to the `Configure Integrations` page for your project

2. Fill in the `Activity Web Hook` as follows:

  * **Web Hook URL:** `https://myghissues.herokuapp.com/issues/<your SECRET_TOKEN>`
  * **API Version:** `v3`

3. Click `Save Web Hook Settings`
