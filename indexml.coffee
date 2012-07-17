
GithubApi = require 'github'
github = new GithubApi version: "3.0.0"

github.authenticate
  type: 'oauth'
  token: process.env.GITHUB_TOKEN

exports.indexml = (req, res) ->
  user = req.params.user
  repo = req.params.repo

  console.log user + '/' + repo

  github.issues.repoIssues
    user: "#{user}"
    repo: "#{repo}"
    per_page: 100
  , (err, result) ->
    if err?
      console.log err

    res.contentType 'text/xml; charset=utf-8'
    output = '<external_stories type="array">'
    for issue in result
      output += generateStory user, repo, issue
    output += '</external_stories>'
    res.end output

generateStory = (user, repo, issue) ->
  str = ""
  str += "<external_story>"
  str +=   "<external_id>#{user}/#{repo}/issues/#{issue.number}</external_id>"
  str +=   "<name>#{issue.title}</name>"
  str +=   "<description>#{issue.body.replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/&/g, '&amp;')}</description>"
  str +=   "<requested_by>#{issue.user.login}</requested_by>"
  str +=   "<created_at type=\"datetime\">#{issue.created_at}</created_at>"
  str +=   "<story_type>bug</story_type>"
  str += "</external_story>"
  str
