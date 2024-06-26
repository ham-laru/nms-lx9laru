{
  programs.starship = {
    enable = true;
    settings = builtins.fromTOML ''
      command_timeout = 2000

      [directory]
      format = "[  $path ]($style)"
      style = "fg:bright-blue"

      [git_branch]
      # format = '[ $symbol$branch(:$remote_branch) ]($style)'
      symbol = "  "
      # style = "fg:#1C3A5E bg:#FCF392"

      # [git_status]
      # format = '[$all_status]($style)'
      # style = "fg:#1C3A5E bg:#FCF392"

      # [git_metrics]
      # format = "([+$added]($added_style))[]($added_style)"
      # added_style = "fg:#1C3A5E bg:#FCF392"
      # deleted_style = "fg:bright-red bg:235"
      # disabled = false

      # [hostname]
      # ssh_only = true
      # disabled = false

      [cmd_duration]
      format = "[  $duration ]($style)"
      style = "fg:bright-white"

      [character]
      success_symbol = '[ ➜](bold green) '
      error_symbol = '[ ✗](#E84D44) '

      [time]
      disabled = false
      time_format = "%R" # Hour:Minute Format
      style = "fg:bright-white"
      format = '[ 󱑍 $time ]($style)'

      [os]
      disabled = false

      [direnv]
      disabled = false
    '';
  };


}
