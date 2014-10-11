# modules
gulp = require 'gulp'
gulpLoadPlugins = require 'gulp-load-plugins'
runSequence = require 'run-sequence'
pngcrush = require 'imagemin-pngcrush'
del = require 'del'
plugins = gulpLoadPlugins()

# arguments
console.log 'env.type : ', plugins.util.env.type
isProduction = plugins.util.env.type is 'production'
console.log 'isProduction : ', isProduction

# jade
gulp.task 'jade', ->
  dest = if isProduction then 'production' else 'development'
  gulp.src 'development/_src/*.jade'
    .pipe plugins.jade locals: production: isProduction
    .pipe gulp.dest dest

# sass
gulp.task 'sass', ->
  dest = if isProduction then 'production' else 'development'
  gulp.src 'development/assets/css/_src/*.scss'
    .pipe plugins.sass()
    .pipe plugins.autoprefixer browsers: ['last 2 versions']
    .pipe if isProduction then plugins.concat 'all.min.css' else plugins.util.noop()
    .pipe if isProduction then plugins.minifyCss() else plugins.util.noop()
    .pipe gulp.dest dest + '/assets/css'

# coffee
gulp.task 'coffee', ->
  dest = if isProduction then 'production' else 'development'
  gulp.src 'development/assets/js/_src/*.coffee'
    .pipe plugins.coffee()
    .pipe if isProduction then plugins.concat 'all.min.js' else plugins.util.noop()
    .pipe if isProduction then plugins.uglify() else plugins.util.noop()
    .pipe gulp.dest dest + '/assets/js'

# imagemin
gulp.task 'imagemin', ->
  gulp.src 'development/assets/img/*'
    .pipe plugins.imagemin
      optimizationLevel: 4
      progressive: true
      use: [pngcrush()]
    .pipe gulp.dest 'production/assets/img'

# webserver
gulp.task 'webserver', ->
  src = if isProduction then 'production' else 'development'
  gulp.src src
    .pipe plugins.webserver
      port: 8000
      livereload: isProduction
      directoryListing: false
      open: true

# watch
gulp.task 'watch', ->
  gulp.watch 'development/_src/*.jade', ['jade']
  gulp.watch 'development/assets/css/_src/*.scss', ['sass']
  gulp.watch 'development/assets/js/_src/*.coffee', ['coffee']
  return

# clean
gulp.task 'clean', (cb) ->
  del ['production'], cb
  return

# default
gulp.task 'default', ->
  if isProduction
    runSequence 'clean', [
      'jade'
      'sass'
      'coffee'
      'imagemin'
    ], 'webserver'
  else
    runSequence [
      'jade'
      'sass'
      'coffee'
    ], 'webserver', 'watch'
  return