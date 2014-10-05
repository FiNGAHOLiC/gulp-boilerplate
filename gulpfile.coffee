# modules
gulp = require 'gulp'
imagemin = require 'gulp-imagemin';
jade = require 'gulp-jade'
sass = require 'gulp-sass'
concat = require 'gulp-concat'
uglifyCSS = require 'gulp-minify-css'
coffee = require 'gulp-coffee'
uglifyJS = require 'gulp-uglify'
webserver = require 'gulp-webserver'
watch = require 'gulp-watch'
autoprefixer = require 'gulp-autoprefixer'
gutil = require 'gulp-util'
runSequence = require 'run-sequence'
pngcrush = require 'imagemin-pngcrush';
del = require 'del'

# arguments
console.log 'env.type : ', gutil.env.type
isProduction = gutil.env.type is 'production'
console.log 'isProduction : ', isProduction

# jade
gulp.task 'jade', ->
  dest = if isProduction then 'production' else 'development'
  gulp.src 'development/_src/*.jade'
    .pipe jade locals: production: isProduction
    .pipe gulp.dest dest

# sass
gulp.task 'sass', ->
  dest = if isProduction then 'production' else 'development'
  gulp.src 'development/assets/css/_src/*.scss'
    .pipe sass()
    .pipe autoprefixer browsers: ['last 2 versions']
    .pipe if isProduction then concat 'all.min.css' else gutil.noop()
    .pipe if isProduction then uglifyCSS() else gutil.noop()
    .pipe gulp.dest dest + '/assets/css'

# coffee
gulp.task 'coffee', ->
  dest = if isProduction then 'production' else 'development'
  gulp.src 'development/assets/js/_src/*.coffee'
    .pipe coffee()
    .pipe if isProduction then concat 'all.min.js' else gutil.noop()
    .pipe if isProduction then uglifyJS() else gutil.noop()
    .pipe gulp.dest dest + '/assets/js'

# imagemin
gulp.task 'imagemin', ->
  gulp.src 'development/assets/img/*'
    .pipe imagemin
      optimizationLevel: 4
      progressive: true
      use: [pngcrush()]
    .pipe gulp.dest 'production/assets/img'

# webserver
gulp.task 'webserver', ->
  src = if isProduction then 'production' else 'development'
  gulp.src src
    .pipe webserver
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