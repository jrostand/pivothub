doc = require('xmlbuilder').create()
xml2js = require 'xml2js'

parser = new xml2js.Parser()

GithubApi = require 'github'
github = new GithubApi version: "3.0.0"

github.authenticate
  type: 'oauth'
  token: process.env.GITHUB_TOKEN

exports.issuesList = (req, res) ->
  user = req.params.user
  repo = req.params.repo

  console.log user + '/' + repo

  github.issues.repoIssues
    user: user
    repo: repo
    per_page: 100
  , (err, result) ->
    console.log err if err?

    res.contentType 'text/xml; charset=utf-8'
    xml = generateStories user, repo, result
    res.write xml
    res.end

exports.issueClose = (req, res) ->
  parser.parseString req.body, (err, data) ->
    console.log err if err?

    story = data.activities[0].activity.stories[0].story
    if story.current_state is 'finished'
      storyData = story.other_id.split '/'
      res.end 'OK', 200 if closeIssue storyData[0], storyData[1], storyData[3]

generateStories = (user, repo, issues) ->
  xml = doc.begin 'external_stories',
    'type': 'array'
    'version': '1.0'
  for issue in issues
    story = xml.ele 'external_story'
    story.ele 'external_id', "#{user}/#{repo}/issues/#{issue.number}"
    story.ele 'name', issue.title
    story.ele 'description', issue.body.replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/&/g, '&amp;')
    story.ele 'requested_by', issue.user.login
    story.ele 'created_at', {'type': 'datetime'}, issue.created_at
    story.ele 'story_type', 'feature'
  return xml.toString()

closeIssue = (user, repo, issueId) ->
  github.issues.edit
    user: user
    repo: repo
    number: issueId
    state: 'closed'
  , (err, result) ->
    console.log err if err?
    return true if err.length is 0
