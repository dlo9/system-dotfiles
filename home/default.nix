# Home manager configuration
# - Manual: https://nix-community.github.io/home-manager/index.html#sec-install-nixos-module
# - Config: https://rycee.gitlab.io/home-manager/options.html

{ config, pkgs, lib, inputs, sysCfg, ... }:

with lib;
with types;

let
  cfg = config.home;
in
{
  imports = [
    inputs.base16.homeManagerModule
    ./gui.nix
  ];

  options.home = {
    enable = mkEnableOption "user home management" // { default = true; };
  };

  config = mkIf cfg.enable {
    scheme = "${inputs.base16-atelier}/atelier-seaside.yaml";
    #scheme = "${inputs.base16-unclaimed}/apathy.yaml";

    home = {
      stateVersion = "22.05";
      sessionPath = [
        "$HOME/.cargo/bin"
        "$HOME/.local/bin"
      ];

      sessionVariables = {
        EDITOR = "${config.programs.vim.package}/bin/vim";
        SOPS_AGE_KEY_FILE = "/var/sops-age-keys.txt";
      };

      shellAliases = {
        k = "kubectl";
      };
    };

    # Allow user-installed fonts
    fonts.fontconfig.enable = true;

    programs = {
      git = {
        enable = true;
        userName = "David Orchard";
        userEmail = "if_coding@fastmail.com";

        difftastic.enable = true;

        ignores = [
          # Temporary files
          "*~"
          "*.swp"
          "*.swo"

          # Backups
          "*.old"

          # Logs
          "*.log"
        ];

        extraConfig = {
          init.defaultBranch = "main";
          pull.ff = "only";
        };
      };

      tmux = {
        enable = true;
        sensibleOnTop = true;
        baseIndex = 1;
        clock24 = true;
        keyMode = "vi";
        prefix = "C-b";

        historyLimit = 50000;
        aggressiveResize = true;
        escapeTime = 0;
        terminal = "screen-256color";

        # Spawn a new session when attaching and none exist
        newSession = true;

        plugins = with pkgs.tmuxPlugins // sysCfg.pkgs.tmuxPlugins; [
          {
            plugin = tmux-themepack;
            extraConfig = "set -g @themepack 'powerline/double/purple'";
          }
        ];

        extraConfig = ''
          # Gapless indexing
          set-option -g renumber-windows on

          # easy-to-remember split pane commands
          bind | split-window -h
          bind - split-window -v
          unbind '"'
          unbind %
        '';
      };
      vim = {
        enable = true;

        settings = {
          background = "dark";
          copyindent = true;
          hidden = true;
          number = true;
          relativenumber = true;
          shiftwidth = 2;
          smartcase = true;
          tabstop = 2;
        };


        plugins = with pkgs.vimPlugins // sysCfg.pkgs.vimPlugins; [
          # Statusline
          vim-airline

          # Auto paste mode
          vim-bracketed-paste

          # Autoindent
          vim-yadi

          # Remove extra whitespace
          vim-strip-trailing-whitespace

          # Remember last place
          vim-lastplace

          # Centralize backup/swap/undo files to ~/.vim
          vim-central

          # Theme
          base16-vim
          vim-airline-themes

          # Autocomplete plugins
          coc-nvim # Base
          coc-git
          coc-rust-analyzer
          coc-spell-checker
          coc-vimlsp
          coc-yaml
          coc-java
          coc-go
          coc-highlight
          coc-rome # Webby stuff (JS, TS, JSON, HTML, MD, CSS)
          coc-sh
          coc-docker
        ];

        extraConfig = ''
          """""""""""
          "" Theme ""
          """""""""""

          let base16colorspace=256
          colorscheme base16-${config.scheme.slug}
          let g:airline_theme='base16_${builtins.replaceStrings ["-"] ["_"] config.scheme.slug}'

          """""""""""""
          "" Airline ""
          """""""""""""

          " Enable top bar
          let g:airline#extensions#tabline#enabled = 1

          " Use powerline arrows
          let g:airline_powerline_fonts = 1

          " Disable whitespace notification due to improper theming
          let g:airline#extensions#whitespace#enabled = 0

          """""""""""""
          "" General ""
          """""""""""""

          " Command lines to remember
          set history=80

          " Set to auto read when a file is changed from the outside
          set autoread

          " Use system clipboard for everything
          "set clipboard=unnamed

          " Use system clipboard for yank and paste
          if $WAYLAND_DIRPLAY != ""
            noremap  y  "+y
            noremap  yy  "+yy
            map  p  "+p
            map  P  "+P
          endif

          " Spelling
          " Leader is `\`, so type `\+a` for spelling help
          vmap <leader>a <Plug>(coc-codeaction-selected)
          nmap <leader>a <Plug>(coc-codeaction-selected)

          """"""""
          "" UI ""
          """"""""

          " Number of context lines to keep between cursor and top/bottom of window
          set so=7

          " Show available options for command tab completion
          set wildmenu

          "Always show cursor position
          set ruler

          " A buffer becomes hidden when it is abandoned
          set hid

          " Backspace should delete all characters
          set backspace=indent,eol,start

          " Move to next line when at EOL
          set whichwrap+=<,>,h,l

          " Don't redraw while executing macros
          set lazyredraw

          " Use GREP regex characters
          set magic

          " Show matching brackets when cursor is over them
          set showmatch

          " No annoying sound on errors
          set noerrorbells
          set novisualbell
          set t_vb=
          set tm=500

          """"""""""""
          "" Search ""
          """"""""""""

          " Ignore case
          set ignorecase

          " Unless the search contains a capital
          set smartcase

          " Highlight results
          set hlsearch

          " Search as you type
          set incsearch

          """""""""""""""""""
          "" File encoding ""
          """""""""""""""""""

          " Set utf8 as standard encoding
          set encoding=utf8

          " Use Unix as the standard file type
          set ffs=unix,dos,mac

          """"""""""""""""""""""""""""""""""
          "" Text, tab and indent related ""
          """"""""""""""""""""""""""""""""""

          " Try to auto detect and use the indentation of a file when opened.
          autocmd BufRead * DetectIndent

          " Otherwise use file type specific indentation
          filetype plugin indent on

          " Set a fallback here in case detection fails and there is no file type
          " plugin available. You can also omit this, then Vim defaults to tabs.
          set expandtab shiftwidth=2 softtabstop=2

          " You stay in control of your tabstop setting.
          set tabstop=2

          " Backspace removes <tabstop> spaces from the start of the line
          set smarttab

          " Linewrap obeys word boundaries
          set linebreak

          """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
          " => Moving around, tabs, windows and buffers
          """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

          " Control+Arrow jumps between words/lines
          map Od <c-left>
          map Ob <c-down>
          map Oa <c-up>
          map Oc <c-right>
          map! Od <c-left>
          map! Ob <c-down>
          map! Oa <c-up>
          map! Oc <c-right>

          " Shift-Tab should behave as expected
          inoremap <Esc>[Z <C-d>

          " TODO: Haven't reviewed past this line
          " Treat long lines as break lines (useful when moving around in them)
          " TODO: doesn't seem to work
          map j gj
          map k gk

          " Disable highlight when <leader><cr> is pressed
          " TODO: doesn't seem to work
          map <silent> <leader><cr> :noh<cr>

          " Faster window jumps
          map <C-j> <C-W>j
          map <C-k> <C-W>k
          map <C-h> <C-W>h
          map <C-l> <C-W>l

          " Close all the buffers
          " TODO: doesn't seem to work (map to q!! or qa if it does?)
          " map <leader>bd :Bclose<cr>
          map <leader>ba :1,1000 bd!<cr>

          " Useful mappings for managing tabs
          map <leader>tn :tabnew<cr>
          map <leader>to :tabonly<cr>
          map <leader>tc :tabclose<cr>
          map <leader>tm :tabmove

          " Remember info about open buffers on close
          " Store up to 1000 lines in each buffer
          set viminfo^=%,<1000

          """"""""""""""""
          """ Filetypes ""
          """"""""""""""""

          autocmd FileType yaml setlocal tabstop=2 expandtab shiftwidth=2 softtabstop=2
          autocmd FileType python setlocal tabstop=4 expandtab shiftwidth=4 softtabstop=4
        '';
      };

      fish = {
        enable = true;

        # FUTURE: use pkgs.fishPlugins.foreign-env
        # https://github.com/nix-community/home-manager/issues/2451
        plugins = [
          {
            # Necessary for sourcing the POSIX shell script for base16-shell
            name = "foreign-env";

            src = pkgs.fetchFromGitHub {
              owner = "oh-my-fish";
              repo = "plugin-foreign-env";
              rev = "dddd9213272a0ab848d474d0cbde12ad034e65bc";
              sha256 = "00xqlyl3lffc5l0viin1nyp819wf81fncqyz87jx8ljjdhilmgbs";
            };
          }
        ];

        interactiveShellInit = ''
          # Theme
          fenv "source ${config.scheme inputs.base16-shell}"

          # Keep fish when using nix-shell
          any-nix-shell fish --info-right | source
        '';

        functions = {
          fish_user_key_bindings = ''
            # Ctrl-Backspace
            bind \e\[3^ kill-word

            # Ctrl-Delete
            bind \b backward-kill-word

            # Delete 'Ctrl-D to exit' binding, which causes accidental terminal exit
            # when ssh'd pagers hit EOF
            # https://stackoverflow.com/questions/34216850/how-to-prevent-iterm2-from-closing-when-typing-ctrl-d-eof
            # In bash, use:
            # https://unix.stackexchange.com/questions/139115/disable-ctrl-d-window-close-in-terminator-terminal-emulator
            bind --erase --preset \cd
          '';

          fork = ''
            eval "$argv & disown > /dev/null"
          '';

          # TODO: pavil only
          fix-hdmi-audio = ''
            amixer -c 0 sset IEC958,1 unmute $argv
          '';
        };
      };

      starship = {
        enable = true;
        enableFishIntegration = true;

        # https://starship.rs/config
        settings = {
          line_break.disabled = true;
          time.disabled = false;
          cmd_duration.min_time = 1000;

          status = {
            disabled = false;
            pipestatus = true;
          };

          # Don't need to know the current rust version
          rust.disabled = true;

          # Which package version this source builds
          package.disabled = true;
        };
      };

      zoxide = {
        enable = true;
        enableFishIntegration = true;
      };
      bottom = {
        enable = true;

        # https://github.com/ClementTsang/bottom/blob/master/sample_configs/default_config.toml
        settings = {
          flags = {
            mem_as_value = true;
          };
        };
      };

    };

    xdg = {
      enable = true;
      configFile = {
        ###############
        ##### Nix #####
        ###############

        "nixpkgs/config.nix".text = ''
          {
            allowUnfree = true;
          }
        '';
        ################
        ##### Wrap #####
        ################

        "wrap.yaml" = {
          onChange = ''
            # This runs without our additional PATH variables, so absolute path must be given
            [ -f $HOME/.cargo/bin/wrap ] && $HOME/.cargo/bin/wrap --alias
          '';

          text = ''
            variables:
              CUTTLEFISH_SSH_PORT: 32085
              CUTTLEFISH_SSH_URL: ssh.sigpanic.com

              DRYWELL_SSH_PORT: 57332
              DRYWELL_SSH_URL: drywell.sigpanic.com

            aliases:
              - alias: drywell
                program: ssh

                keywords:
                  - keys: [--local]
                    values: [192.168.1.200]
                  - keys: [--remote]
                    values: [-p, $DRYWELL_SSH_PORT, $DRYWELL_SSH_URL]

              - alias: cuttlefish
                program: ssh

                keywords:
                  - keys: [--local]
                    values: [192.168.1.230]
                  - keys: [--remote]
                    values: [-p, $CUTTLEFISH_SSH_PORT, $CUTTLEFISH_SSH_URL]

              # System yadm
              # Clone via: syadm clone -w / <repo>
              - alias: syadm
                program: sudo

                arguments:
                  - key: /etc/yadm/data
                  - key: --yadm-data
                  - key: /etc/yadm/config
                  - key: --yadm-dir
                  - key: yadm
                  - key: GIT_SSH_COMMAND=ssh -i $HOME/.ssh/id_rsa
                  - key: HOME=$HOME

              - alias: a
                program: awk

                keywords:
                  - keys: [--unique, -u]
                    values: ['!a[\$0]++']

              - alias: maintain
                program: sh

                arguments:
                  - key: -c

                keywords:
                  - keys: [--bg]
                    values: ['killall swaybg; swaybg -i ~/.config/sway/wallpapers/spaceman.jpg &']

              - alias: theme
                program: sh

                arguments:
                  - key: -c

                keywords:
                  - keys: [--iterate]
                    values:
                      - |
                        for theme in \$(flavours list | awk -v RS=' ' '!/-light/'); do
                          echo \$theme
                          flavours apply \$theme
                          sleep 1
                        done
                  - keys: [--iterate-random]
                    values:
                      - |
                        for theme in \$(flavours list | awk -v RS=' ' '!/-light/' | sort -R); do
                          echo \$theme
                          flavours apply \$theme
                          sleep 1
                        done
                  - keys: [--apply]
                    values: ['flavours apply \$(cat ~/.local/share/flavours/lastscheme)']
                  - keys: [--show]
                    values:
                      - flavours info "\$(flavours current)" | awk '!a[\$0]++'
          '';
        };
      };
    };

    home.packages = with pkgs // sysCfg.pkgs; [
      # Misc dev tools
      jq
      go-task

      any-nix-shell # Doesn't change the interactive shell when using nix-shell
    ];

    systemd.user.startServices = "sd-switch";
  };
}
