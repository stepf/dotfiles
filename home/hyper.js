// Future versions of Hyper may add additional config options,
// which will not automatically be merged into this file.
// See https://hyper.is#cfg for all currently supported options.

module.exports = {
  config: {
    // choose either `'stable'` for receiving highly polished,
    // or `'canary'` for less polished but more frequent updates
    updateChannel: "stable",

    webGLRenderer: true,

    // default font size in pixels for all tabs
    fontSize: 15,

    // font family with optional fallbacks
    fontFamily: '"MD IO Trial", "ia Writer Mono V Text"',

    // default font weight: 'normal' or 'bold'
    fontWeight: "normal",

    // font weight for bold characters: 'normal' or 'bold'
    fontWeightBold: "bold",

    // line height as a relative unit
    lineHeight: 1.6,

    // letter spacing as a relative unit
    letterSpacing: 0,

    // terminal cursor background color and opacity (hex, rgb, hsl, hsv, hwb or cmyk)
    cursorColor: "#BAD5F8",

    // terminal text color under BLOCK cursor
    cursorAccentColor: "#413F43",

    // `'BEAM'` for |, `'UNDERLINE'` for _, `'BLOCK'` for █
    cursorShape: "BEAM",

    // set to `true` (without backticks and without quotes) for blinking cursor
    cursorBlink: false,

    // color of the text
    foregroundColor: "#413F43",

    // terminal background color
    // opacity is only supported on macOS
    backgroundColor: "#FAFAFB",

    // terminal selection color
    selectionColor: "#BAD5F8",

    // border color (window, tabs)
    borderColor: "#CCCCCC",

    // custom CSS to embed in the main window
    css: "",

    // custom CSS to embed in the terminal window
    termCSS: "",

    // if you're using a Linux setup which show native menus, set to false
    // default: `true` on Linux, `true` on Windows, ignored on macOS
    showHamburgerMenu: "",

    // set to `false` (without backticks and without quotes) if you want to hide the minimize, maximize and close buttons
    // additionally, set to `'left'` if you want them on the left, like in Ubuntu
    // default: `true` (without backticks and without quotes) on Windows and Linux, ignored on macOS
    showWindowControls: "",

    // custom padding (CSS format, i.e.: `top right bottom left`)
    padding: "12px 32px 6px 32px",

    // the full list. if you're going to provide the full color palette,
    // including the 6 x 6 color cubes and the grayscale map, just provide
    // an array here instead of a color map object
    colors: {
      black: "#575F66",
      red: "#F51818",
      green: "#86B300",
      yellow: "#F2AE49",
      blue: "#399EE6",
      magenta: "#A37ACC",
      cyan: "#4CBF99",
      white: "#FAFAFA",
      lightBlack: "#8A9199",
      lightRed: "#F51818",
      lightGreen: "#86B300",
      lightYellow: "#F2AE49",
      lightBlue: "#399EE6",
      lightMagenta: "#A37ACC",
      lightCyan: "#4CBF99",
      lightWhite: "#FAFAFA",
    },

    // the shell to run when spawning a new session (i.e. /usr/local/bin/fish)
    // if left empty, your system's login shell will be used by default
    //
    // Windows
    // - Make sure to use a full path if the binary name doesn't work
    // - Remove `--login` in shellArgs
    //
    // Bash on Windows
    // - Example: `C:\\Windows\\System32\\bash.exe`
    //
    // PowerShell on Windows
    // - Example: `C:\\WINDOWS\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`
    shell: "",

    // for setting shell arguments (i.e. for using interactive shellArgs: `['-i']`)
    // by default `['--login']` will be used
    shellArgs: ["--login"],

    // for environment variables
    env: {},

    // set to `false` for no bell
    bell: "SOUND",

    // if `true` (without backticks and without quotes), selected text will automatically be copied to the clipboard
    copyOnSelect: false,

    // if `true` (without backticks and without quotes), hyper will be set as the default protocol client for SSH
    defaultSSHApp: true,

    // if `true` (without backticks and without quotes), on right click selected text will be copied or pasted if no
    // selection is present (`true` by default on Windows and disables the context menu feature)
    // quickEdit: true,

    // URL to custom bell
    // bellSoundURL: 'http://example.com/bell.mp3',

    // for advanced config flags please refer to https://hyper.is/#cfg

    colorScheme: {
      dark: 'ayu-mirage',
      light: 'default',
    },

    profiles: [
      {
        name: "ayu-mirage",
        config: {
          backgroundColor: "#212733",
          foregroundColor: "#D9D7CE",
          cursorColor: "#FFD580",
          borderColor: "#212733",
          selectionColor: "#3A4B65",
          colors: {
            black: "#1F2430",
            red: "#FF3333",
            green: "#BAE67E",
            yellow: "#FFD580",
            blue: "#73D0FF",
            magenta: "#D4BFFF",
            cyan: "#5CCFE6",
            white: "#737D87",
            lightBlack: "#707A8C",
            lightRed: "#FF3333",
            lightGreen: "#BAE67E",
            lightYellow: "#FFA759",
            lightBlue: "#73D0FF",
            lightMagenta: "#D4BFFF",
            lightCyan: "#95E6CB",
            lightWhite: "#CBCCC6",
            colorCubes: "#FFFFFF",
            grayscale: "#B8B4A3",
          },
        },
      },
      {
        name: "default",
        config: { },
      },
    ],
  },

  // a list of plugins to fetch and install from npm
  // format: [@org/]project[#version]
  // examples:
  //   `hyperpower`
  //   `@company/project`
  //   `project#1.0.1`
  plugins: [
    "hyper-sync-color-scheme",
    "hyper-custom-touchbar",
    "hyper-search",
    "hyper-font-ligatures",
  ],

  // in development, you can create a directory under
  // `~/.hyper_plugins/local/` and include it here
  // to load it and avoid it being `npm install`ed
  localPlugins: [],

  keymaps: {
    // Example
    // 'window:devtools': 'cmd+alt+o',
  },
};
