class TopController < ApplicationController

  def index
    repos_url = "https://api.github.com/orgs/#{MY_APP['github']['org']}/repos";
    @repo_list = github_api(repos_url)
    @repo_list.sort! do |a, b|
      b["pushed_at"] <=> a["pushed_at"]
    end

    member_url = "https://api.github.com/orgs/#{MY_APP['github']['org']}/members";
    @member_list = github_api(member_url)
  end

  def get_issues
    repo_name = params[:repo_name]
    mentioned = params[:mentioned]

    issues_url = "https://api.github.com/repos/#{MY_APP['github']['org']}/#{repo_name}/issues"
    issues_url << "?since=#{(DateTime.now << 1).iso8601}"
    issues_url << "&mentioned=#{mentioned}" if mentioned.present?
    issues_list = github_api(issues_url)
    issues_list.each_with_index do |issue, i|
      issues_list[i]["created_at_format"] = Time.parse(issue["created_at"]).getlocal.strftime("%Y/%m/%d %H:%M:%S")
    end

    render :json => issues_list
  end

  private
  def github_api url
    json = nil
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port, MY_APP['github']['proxy_host'], MY_APP['github']['proxy_port'])
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    http.start do
      req = Net::HTTP::Get.new(uri.request_uri)
      if MY_APP['github']['user'].present? && MY_APP['github']['pass'].present?
        req.basic_auth MY_APP['github']['user'], MY_APP['github']['pass']
      end
      response = http.request(req)
      json = JSON.parse(response.body) if response.present?
    end
    json
  end
end
