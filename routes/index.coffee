xml2js = require 'xml2js'
GithubApi = require 'github'
util = require 'util'

parser = new xml2js.Parser()
github = new GithubApi version: "3.0.0"

github.authenticate
  type: 'oauth'
  token: process.env.GITHUB_TOKEN

exports.issuesList = (req, res) ->
  user = req.params.user
  repo = req.params.repo

  console.log "Sending issues for #{user}/#{repo}..."

  github.issues.repoIssues
    user: user
    repo: repo
    per_page: 100
  , (err, result) ->
    console.log err if err?

    res.contentType 'text/xml; charset=utf-8'
    xml = generateStories user, repo, result
    res.send xml

exports.issueClose = (req, res) ->
  res.send 'Unauthorized', 401 unless req.params.token is process.env.SECRET_TOKEN
  console.log 'Receiving activity POST...'

  story = req.body.stories.story
  if story.current_state is 'finished'
    storyData = story.other_id.split '/'
    if closeIssue storyData[0], storyData[1], storyData[3]
      res.send 'OK'
    else
      res.send 'Failure', 400
  else
    res.end 'OK'

generateStories = (user, repo, issues) ->
  xml = '<external_stories type="array">'
  for issue in issues
    xml += """
           <external_story>
             <external_id>#{user}/#{repo}/issues/#{issue.number}</external_id>
             <name>#{issue.title.replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/&/g, '&amp;')}</name>
             <description>#{issue.body.replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/&/g, '&amp;')}</description>
             <requested_by>#{issue.user.login}</requested_by>
             <created_at type=\"datetime\">#{issue.created_at}</created_at>
             <story_type>feature</story_type>
           </external_story>
           """
  xml += '</external_stories>'
  return xml

closeIssue = (user, repo, issueId) ->
  github.issues.edit
    user: user
    repo: repo
    number: issueId
    state: 'closed'
  , (err, result) ->
    console.log err if err?
