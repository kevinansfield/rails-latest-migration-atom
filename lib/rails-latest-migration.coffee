fs = require 'fs'
Path = require 'path'

module.exports =
  activate: ->
    atom.workspaceView.command "rails-latest-migration:find", => @find()

  find: ->
    dir = atom.project.getRootDirectory()

    if @isRailsDir(dir)
      latest_migration_path = @getLatestMigration(dir)
      if latest_migration_path
        atom.workspace.open(latest_migration_path)
      else
        alert "Uh oh! Could not find any migrations in your db/migrate directory. Please add some and try again."
    else
      alert "Uh oh! This doesn't look like a Rails project. Please open up the root of a Rails app and try again."

  isRailsDir: (dir) ->
    expected_rails_files = ['app', 'db', 'config', 'Gemfile']
    entries = dir.getEntriesSync()
    matching_dirs = []

    entries.forEach (entry) ->
      if expected_rails_files.indexOf(entry.getBaseName()) > -1
        matching_dirs.push(entry)

    return expected_rails_files.length == matching_dirs.length

  getMigrationsDir: (dir) ->
    Path.join(dir.getPath(), 'db', 'migrate')

  getLatestMigration: (dir) ->
    migrations_dir = @getMigrationsDir(dir)
    migrations = fs.readdirSync(migrations_dir).filter (elem) ->
      stat = fs.statSync(Path.join(migrations_dir, elem))
      return stat.isFile()

    if migrations.length
      Path.join(migrations_dir, migrations[migrations.length-1])
