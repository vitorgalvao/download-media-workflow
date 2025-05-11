#!/usr/bin/env ruby

require 'cgi'
require 'json'
require 'open3'
require 'pathname'

# Constants
Audio_only_format = ENV['audio_only_format']
Advanced_format = ENV['advanced_format']
Download_dir = Pathname.new(ENV['download_dir'])
Single_title_template = ENV['single_title_template']

Pid_file = Pathname(ENV['alfred_workflow_cache']).join('pid.txt')
Progress_file = Pathname(ENV['alfred_workflow_cache']).join('progress.txt')
Query_file = Pathname(ENV['alfred_workflow_cache']).join('query.json')

def show_progress
  ensure_data_paths

  script_filter_items = []

  if Progress_file.exist?
    progress_lines = Progress_file.readlines.select { |line| line.start_with?('[download]') }.map { |line| line.sub(%r{^\[download\] }, '').strip }
    progress = progress_lines.last.strip rescue 'Getting progress info…'
    destination = Pathname(progress_lines.select { |line| line.start_with?('Destination:') }.last.sub('Destination: ', '')).basename rescue 'Getting destination name…'

    script_filter_items.push(
      uid: 'downmedia progress',
      title: progress,
      subtitle: destination,
      valid: false,
      mods: {
        cmd: {
          subtitle: 'Restart download at bottom of queue',
          valid: true,
          variables: { after_kill: 'restart' }
        },
        ctrl: {
          arg: 'abort',
          subtitle: 'Abort download',
          valid: true,
          variables: { after_kill: 'nothing' }
        }
      }
    )
  else
    script_filter_items.push(
      uid: 'downmedia progress',
      title: 'No Download in Progress',
      subtitle: 'Will auto-refresh if a download starts',
      valid: false
    )
  end

  puts({ rerun: 1, items: script_filter_items }.to_json)
end

def download_url(url, media_type)
  # Setup
  encoded_url = CGI.escape_html(url)
  title_template = Single_title_template

  # Video format is forced for consistency between --print filename and what is downloaded
  flags = media_type == 'audio' ?
    ['--extract-audio', '--audio-quality', '0', '--audio-format', Audio_only_format] :
    ['--sub-langs', 'all,-live_chat', '--embed-subs', '--format', Advanced_format]

  flags.push('--no-playlist', '--ignore-errors', '--embed-chapters', '--output', Download_dir.join(title_template).to_path, url)

  # May fail in certain situations, due to bugs in getting the filename beforehand
  # https://github.com/ytdl-org/youtube-dl/issues/5710
  # https://github.com/ytdl-org/youtube-dl/issues/7137
  get_filename = Open3.capture2('yt-dlp', '--simulate', '--print', 'filename', *flags).first.strip

  save_path = Pathname(get_filename)
  title = save_path.basename(save_path.extname).to_path

  # Download
  error('Download failed', 'The URL is invalid') if get_filename.empty?
  notification("Downloading #{media_type.capitalize}", title)

  error('Download failed', 'You may be able to restart it with `dp`') unless system('yt-dlp', '--newline', *flags, out: Progress_file.to_path)
  notification('Download successful', title)

  # xattr returns before the action is complete, not giving enough time for the file to have the attribute before sending to Watch List, so only continue after the attribute is present
  system('/usr/bin/xattr', '-w', 'com.apple.metadata:kMDItemWhereFroms', "<!DOCTYPE plist PUBLIC '-//Apple//DTD PLIST 1.0//EN' 'http://www.apple.com/DTDs/PropertyList-1.0.dtd'><plist version='1.0'><array><string>#{encoded_url}</string></array></plist>", save_path.to_path)
  sleep 1 while Open3.capture2('mdls', '-raw', '-name', 'kMDItemWhereFroms', save_path.to_path).first == '(null)'

  cleanup_tmp_files
  print(save_path.to_path) # Output path so it can be sent to Watch List
end

def save_query(url, media_type)
  ensure_data_paths

  Query_file.write({
    alfredworkflow: {
      variables: { media_type: media_type },
      arg: url
    }
  }.to_json)
end

def save_pid(pid)
  ensure_data_paths

  Pid_file.write(pid.to_s)
end

def kill_download
  # Kill process tree to stop download and prevent notification from showing success
  process_groud_id = Open3.capture2('/bin/ps', '-o', 'pgid=', Pid_file.read).first.strip
  system('kill', '--', "-#{process_groud_id}")
end

def notification(title, message)
  system("#{Dir.pwd}/notificator", '--message', message, '--title', title)
end

def error(title, message)
  notification(title, message)
  abort
end

def ensure_data_paths
  Pathname(ENV['alfred_workflow_cache']).mkpath
end

def cleanup_tmp_files
  Pid_file.delete
  Progress_file.delete
  Query_file.delete
end
