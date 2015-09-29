# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

urlAutoLink = (str) -> str.replace(/\r?\n/g, '<br>').replace(/(https?:\/\/[\w\-\.!~\*\';\/\?:&@=\+\$,%#\[\]]+)/gi, "<a href='$1' target='_blank'>$1</a>")

setRepoCookie = () ->
  data_hash = []
  $('.disp_repo_check[type="checkbox"]:not(:checked)').each ->
    data_hash.push($(this).data("repo"))
  $.cookie('non_disp_repos',
            JSON.stringify(data_hash),
           {'expires': 365, 'path': '/'}
          )

getIssue = (repo_name, target_area) ->
  dataHash = {}
  if $('#mentioned').length > 0
    dataHash.mentioned = $('#mentioned').val()

  if $('#creator').length > 0
    dataHash.creator = $('#creator').val()

  $.ajax "/get_issues/#{repo_name}",
    async: true
    type: 'GET'
    dataType: 'json'
    data: dataHash
    error: (jqXHR, textStatus, errorThrown) ->
      console.log(textStatus)
    success: (data, textStatus, jqXHR) ->
      if !data || Object.keys(data).length == 0
        target_area.html('')
        $('#side_repo_name_' + repo_name + ' a').html(repo_name).css("color","")
        return

      inshtml = '<div class="panel panel-default"><table class="table table-bordered">'
      for i,value of data
        inshtml += "<tr>"
        inshtml += "<td>"
        inshtml += "<h4 class=\"issue-title\"><a href=\"#{value.html_url}\" target=\"_blank\"><u>#{value.title}</u></a></h4>"
        if value.labels
          for j,label of value.labels
            inshtml += '<span class="issue-label" style="background-color:#' + label.color + '">' + label.name + '</span>'
        inshtml += "<p>##{value.number} opened #{value.created_at_format} by #{value.user.login} </p>"
        inshtml += '<div style="float: left; margin-right: 1em;">'
        inshtml += "<img src=\"#{value.user.avatar_url}\" class=\"img-responsive\" alt=\"#{value.user.login}\" height=\"48\" width=\"48\">"
        inshtml += "</div>"
        if value.body
          inshtml += "<p>" + urlAutoLink(value.body) + "</p>"
        inshtml += "<span class=\"glyphicon glyphicon-comment\"></span> #{value.comments}"
        inshtml += '</td>'
        inshtml += '</tr>'
      inshtml += '</table></div>'
      target_area.html(inshtml)
      $('#side_repo_name_' + repo_name + ' a').html(repo_name + '(' + Object.keys(data).length + ')').css("color","red")

$('.disp_repo_check[type="checkbox"]:checked').each ->
  repo_name = $(this).data("repo")
  target_area = $('#issues_area_' + repo_name)
  getIssue(repo_name, target_area)

$('.disp_repo_check').on "change", ->
  repo_name = $(this).data("repo")
  target_area = $('#issues_area_' + repo_name)
  if $(this).is(':checked')
    $('#main_area_' + repo_name).show()
    getIssue(repo_name, target_area)
  else
    $('#main_area_' + repo_name).hide()
    $('#side_repo_name_' + repo_name + ' a').html(repo_name).css("color","")

  setRepoCookie()

$('#all_repo_check').on "click", ->
  $('.disp_repo_check[type="checkbox"]').prop('checked', true).change()

$('#mentioned').on "change", ->
  $('.disp_repo_check[type="checkbox"]:checked').each ->
    repo_name = $(this).data("repo")
    target_area = $('#issues_area_' + repo_name)
    getIssue(repo_name, target_area)
  $.cookie('mentioned',
            $(this).val(),
           {'expires': 365, 'path': '/'}
          )

$('#creator').on "change", ->
  $('.disp_repo_check[type="checkbox"]:checked').each ->
    repo_name = $(this).data("repo")
    target_area = $('#issues_area_' + repo_name)
    getIssue(repo_name, target_area)
  $.cookie('creator',
            $(this).val(),
           {'expires': 365, 'path': '/'}
          )
