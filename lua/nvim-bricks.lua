local P = require("plenary")

local extend_env_var = function (name, path, separator, prepend)
  separator = separator or ":"

  if not vim.env[name] then
    vim.env[name] = path
    return
  end

  local paths = vim.split(vim.env[name], separator)

  if not vim.tbl_contains(paths, path) then
    if prepend then
      vim.env[name] = path .. separator .. vim.env[name]
    else
      vim.env[name] = vim.env[name] .. separator .. path
    end
  end
end

local append_to_env_var = function (name, path, separator)
  extend_env_var (name, path, separator)
end

local prepend_to_env_var = function (name, path, separator)
  extend_env_var (name, path, separator, true)
end

local dir_exists = function (target)
  local path = P.path:new(target)

  if path:exists() and path:is_dir() then
    return true
  end
end

local file_exists = function (target)
  local path = P.path:new(target)

  if path:exists() and path:is_file() then
    return true
  end

  return false
end

local python_lib_dir = function(path)
  local config_file = path .. "/pyvenv.cfg"

  local file = io.open(config_file, "r")

  if not file then
    return
  end

  local line = file:read()

  while line do
    local m_start, m_end = line:find('^%s*version%s*=%s*')

    if m_start == 1 then
      local v = vim.split(line:sub(m_end + 1), "%.")
      local python_lib = string.format("%s/lib/python%s.%s/site-packages", path, v[1], v[2])

      file:close()

      return python_lib
    end

    line = file:read()
  end

  file:close()
end


-- ============================================================================
-- prepend bin path for various packages to env PATH
--
local nvim_share  = vim.fn.stdpath('data')
local bricks_path = nvim_share .. '/bricks'

local node_path   = bricks_path .. "/node"
local cargo_path  = bricks_path .. "/cargo"
local python_path = bricks_path .. "/python"
local perl_path   = bricks_path .. "/perl5"
local lua_path    = bricks_path .. "/lua"

local node_bin   = node_path   .. "/bin"
local cargo_bin  = cargo_path  .. "/bin"
local python_bin = python_path .. "/bin/python3"
local perl_bin   = perl_path   .. "/bin"

local perl_lib   = perl_path   .. "/lib/perl5"
local lua_lib    = lua_path    .. "/lib/lua/5.1"
local python_lib = python_lib_dir(python_path)


-- register brick's "cargo" home
--
if dir_exists(cargo_bin) then
  prepend_to_env_var ("PATH", cargo_bin)
end

-- register brick's "npm" home
--
if dir_exists(node_bin) then
  prepend_to_env_var ("PATH", node_bin)
  vim.env.npm_config_prefix = node_path
end

-- register brick's "perl" home
--
if dir_exists (perl_bin) then
  prepend_to_env_var ("PATH", perl_bin)
  vim.env.PERL5LIB = perl_lib
  vim.env.PERL_MB_OPT = string.format('--install_base "%s"',  perl_path)
  vim.env.PERL_MM_OPT = "INSTALL_BASE=" .. perl_path
  vim.env.PERL_LOCAL_LIB_ROOT = perl_path
end

-- register brick's "lua" home
--
if dir_exists (lua_lib) then
  package.cpath = package.cpath .. ';' .. lua_lib .. '/?.so'
  package.path  = package.path  .. ';' .. lua_lib .. '/?.lua'
  package.path  = package.path  .. ';' .. lua_lib .. '/?/init.lua'
end

-- register brick's "python" home
--
if file_exists (python_bin) then
  if python_lib then
    prepend_to_env_var("PYTHONPATH", python_lib)
  end

  vim.g.python3_host_prog = python_bin
end


-- ==================================================================
-- NOTE:
--   In shell environment for perl is initiated by issuig command:
--
--     eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)"
--
--  which modifies environment variables, as we have above. If there
--  are any problems, check above comand and it's effect.
