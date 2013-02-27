# PivotHub

A simple way to integrate GitHub Issues into Pivotal Tracker

## Installation

1. Clone the repo

  ```shell
  git clone https://github.com/jrostand/pivothub.git
  ```

2. Get an OAuth key from GitHub. Instructions are available [here](https://help.github.com/articles/creating-an-oauth-token-for-command-line-use)

3. Set up your deployment environment. I use [Heroku](http://www.heroku.com) personally (because you get SSL for free), but it should work equally well with other providers. Note that using SSL is highly recommended as otherwise your credentials will be transmitted in the clear.

  ```shell
  cp config.json.example config.json
  ```
  You'll need to edit `config.json` to suit your needs. Explanations of the flags are in the file.

4. Deploy it!

## Setting up Pivotal Tracker

This section will tell you how to set up Pivotal Tracker to pull in GitHub Issues as well as close Issues that are associated with Finished stories.

### Assumptions

* Your application is deployed at `https://myghissues.herokuapp.com`
* Your GitHub project is at `https://github.com/myaccount/repo`

### Pulling Issues into Pivotal

1. Select `Project` and then `Configure Integrations`

2. Scroll down to **External Tool Integrations** and select `Other` from the options in the `Create New Integration...` box

3. Fill in the form with this information:
    * **Name:** Whatever you'd like to call the Issues panel (e.g., GitHub Issues)
    * **Basic Auth Username:** The value of `basicUsername` in the config
    * **Basic Auth Password:** The value of `basicPassword` in the config
    * **Base URL:** `https://github.com/`
    * **Import API URL:** `https://myghissues.herokuapp.com/issues/myaccount/repo`

4. Click **Create**

### Closing Issues from Finished stories

If you would like PivotHub to close Issues that are associated with Finished stories, here's how to set that up:

1. In Pivotal, go to the `Configure Integrations` page for your project

2. Fill in the **Activity Web Hook** fields as follows:
  * **Web Hook URL:** `https://myghissues.herokuapp.com/issues/<secretToken>`
  * **API Version:** `v3`

3. Click **Save Web Hook Settings**

## License

MIT license. See [the license file](MIT-LICENSE.md).

## Authors

* Original author: [Julien Rostand](https://github.com/jrostand)
* Major contributor: [Tom Lianza](https://github.com/tlianza)
