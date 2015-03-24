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
  gulp.src ['development/_src/**/*.jade', '!development/_src/**/_*.jade']
  .pipe plugins.jade
    pretty: true
  .pipe plugins.size showFiles: true
  .pipe gulp.dest 'development/'

# sass
gulp.task 'sass', ->
  gulp.src ['development/assets/css/_src/**/*.scss', '!development/assets/css/_src/**/_*.scss']
  .pipe plugins.plumber()
  .pipe plugins.sass()
  .pipe plugins.autoprefixer browsers: ['last 2 versions']
  .pipe plugins.size showFiles: true
  .pipe gulp.dest 'development/assets/css'

# coffee
gulp.task 'coffee', ->
  gulp.src 'development/assets/js/_src/**/*.coffee'
  .pipe plugins.coffee()
  .pipe plugins.size showFiles: true
  .pipe gulp.dest 'development/assets/js'

# sprite
gulp.task 'sprite', ->
  spriteData = gulp.src 'development/assets/img/sprite/_src/*.png'
  .pipe plugins.spritesmith
    imgName: 'sprite.png'
    cssName: '_sprite.scss'
    imgPath: '/assets/img/sprite/sprite.png'
    cssOpts:
      functions: false
    algorithm: 'diagonal'
  spriteData.img.pipe gulp.dest 'development/assets/img/sprite/'
  spriteData.css.pipe gulp.dest 'development/assets/css/_src/'

# imagemin
gulp.task 'imagemin', ->
  gulp.src ['development/assets/img/**/*', '!development/assets/img/**/_src', '!development/assets/img/**/_src/*']
  .pipe plugins.imagemin
    optimizationLevel: 4
    progressive: true
    use: [pngcrush()]
  .pipe gulp.dest 'production/assets/img'

# html
gulp.task 'html', ->
  assets = plugins.useref.assets();
  gulp.src 'development/*.html'
  .pipe assets
  # minifyしたい場合はアンコメントする
  # .pipe plugins.if '*.css', plugins.minifyCss()
  # .pipe plugins.if '*.js', plugins.uglify()
  .pipe assets.restore()
  .pipe plugins.useref()
  .pipe gulp.dest 'production'

# webserver
gulp.task 'webserver', ->
  src = if isProduction then 'production' else 'development'
  gulp.src src
  .pipe plugins.webserver
    port: 8000
    livereload: not isProduction
    directoryListing: false
    open: true

# watch
gulp.task 'watch', ->
  gulp.watch 'development/_src/**/*.jade', ['jade']
  gulp.watch 'development/assets/js/_src/**/*.coffee', ['coffee']
  gulp.watch 'development/assets/css/_src/**/*.scss', ['sass']

# clean
gulp.task 'clean', (cb) ->
  del ['production'], cb

# default
gulp.task 'default', ->
  if isProduction
    runSequence 'clean', [
        'jade'
        'coffee'
        'sass'
      ], [
        'html'
        'imagemin'
      ],
      'webserver'
  else
    runSequence [
        'jade'
        'coffee'
        'sass'
      ],
      'webserver',
      'watch'