# Gulp Scaffolding

Under Development

## Usage

```bash
$ git clone git@github.com:FiNGAHOLiC/gulp-scaffolding.git
$ npm install
```

## Run Gulp

Development Mode

```bash
gulp
```
1. Compile jade to html
2. Compile coffee to js
3. Compile scss to css
4. Run local server
5. Watch jade, coffee, scss file

Production Mode

```bash
gulp --type production
```

1. Compile jade to html
2. Compile coffee to js (concat and minify)
3. Compile scss to css (concat and minify)
4. Optimize image
5. Run local server