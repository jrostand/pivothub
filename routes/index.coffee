xml2js = require 'xml2js'
GithubApi = require 'github'
util = require 'util'
config = require '../config'

parser = new xml2js.Parser()
github = new GithubApi version: "3.0.0"

github.authenticate
  type: 'oauth'
  token: config.githubToken

exports.default = (req, res) ->
  res.send config

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

exports.issueHandle = (req, res) ->
  res.send 'Unauthorized', 401 unless req.params.token is config.secretToken
  console.log 'Receiving activity POST...'

  activity  = req.body.activity
  story     = activity.stories[0].story[0]
  storyData = story.other_id[0].split '/'

  user    = storyData[0]
  repo    = storyData[1]
  issueId = storyData[3]
  # storyData[2] is not used - it's always "issues" for the record
  
  if config.closeIssues? and story.current_state and story.current_state[0] is config.closeOn
    if closeIssue user, repo, issueId
      res.send 'OK'
    else res.send 'Failure', 400
  else if config.updateComments? and story.notes and story.notes[0].note
    if addIssueComment(user,
                       repo,
                       issueId,
                       "#{activity.description}\nhttps://www.pivotaltracker.com/story/show/#{story.id[0]._}")
      res.send 'OK'
    else res.send 'Failure', 400
  else res.end 'OK'

generateStories = (user, repo, issues) ->
  xml = '<external_stories type="array">'
  for issue in issues
    xml += """
           <external_story>
             <external_id>#{user}/#{repo}/issues/#{issue.number}</external_id>
             <name>#{stringTidy(issue.title)}</name>
             <description>#{stringTidy(issue.body)}</description>
             <requested_by>#{issue.user.login}</requested_by>
             <created_at type=\"datetime\">#{issue.created_at}</created_at>
             <story_type>feature</story_type>
           </external_story>
           """
  xml += '</external_stories>'
  return xml

closeIssue = (user, repo, issueId, success, failure) ->
  github.issues.edit
    user: user
    repo: repo
    number: issueId
    state: 'closed'
  , (err, result) ->
    console.log err if err?

addIssueComment = (user, repo, issueId, comment) ->
  github.issues.createComment
    user: user
    repo: repo
    number: issueId
    body: comment
  , (err, result) ->
    console.log err if err?

stringTidy = (string) ->
  string.replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/&/g, '&amp;')
