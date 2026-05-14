return {
  -- Framework de testes e o adaptador para JUnit/TestNG
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      'rcasia/neotest-java',
    },
    config = function()
      require('neotest').setup {
        adapters = {
          require 'neotest-java' {
            ignore_wrapper = false,
          },
        },
      }
    end,
    keys = {
      {
        '<leader>tr',
        function()
          require('neotest').run.run()
        end,
        desc = 'Run nearest test',
      },
      {
        '<leader>tf',
        function()
          require('neotest').run.run(vim.fn.expand '%')
        end,
        desc = 'Run current file',
      },
      {
        '<leader>ts',
        function()
          require('neotest').summary.toggle()
        end,
        desc = 'Toggle test summary',
      },
    },
  },
  -- Cliente nativo de Banco de Dados
  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      { 'tpope/vim-dadbod', lazy = true },
      { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
    },
    cmd = {
      'DBUI',
      'DBUIToggle',
      'DBUIAddConnection',
      'DBUIFindBuffer',
    },
    init = function()
      -- Define o uso de ícones NerdFont
      vim.g.db_ui_use_nerd_fonts = 1

      -- Má Prática Evitada: Desativa a execução automática ao salvar.
      -- Em TI, rodar código em banco de dados deve ser sempre uma ação intencional, não um acidente de teclado.
      vim.g.db_ui_execute_on_save = 0
    end,
    keys = {
      { '<leader>db', '<cmd>DBUIToggle<cr>', desc = 'Toggle DB Explorer' },
    },
  },
}
