const fs = require('fs');
const path = require('path');

const projectRoot = 'c:/Users/popur/Documents/Projects/Movie_Imposter';
const t = require(path.join(projectRoot, 'src/data/movies/tollywood.json'));
const b = require(path.join(projectRoot, 'src/data/movies/bollywood.json'));
const h = require(path.join(projectRoot, 'src/data/movies/hollywood.json'));
const s = require(path.join(projectRoot, 'src/data/movies/shows.json'));

const all = [...t, ...b, ...h, ...s];

function escapeDart(str) {
  if (!str) return '';
  return str.replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/\$/g, '\\$');
}

let out = "import '../models/movie.dart';\n\n";
out += "const List<Movie> kAllMovies = <Movie>[\n";

for (const m of all) {
  out += '  Movie(\n';
  out += "    id: '" + escapeDart(m.id) + "',\n";
  out += "    title: '" + escapeDart(m.title) + "',\n";
  out += '    industry: Industry.' + m.industry + ',\n';
  out += '    releaseYear: ' + m.releaseYear + ',\n';
  out += "    decade: '" + escapeDart(m.decade) + "',\n";
  if (m.industry !== 'shows') {
    out += "    hero: '" + escapeDart(m.hero) + "',\n";
    out += "    director: '" + escapeDart(m.director) + "',\n";
    out += "    genre: '" + escapeDart(m.genre) + "',\n";
    out += '    isAdult: ' + (m.isAdult ? 'true' : 'false') + ',\n';
    out += '    isRemake: ' + (m.isRemake ? 'true' : 'false') + ',\n';
  } else {
    if (m.genre) out += "    genre: '" + escapeDart(m.genre) + "',\n";
    if (m.productionHouse) out += "    productionHouse: '" + escapeDart(m.productionHouse) + "',\n";
    if (m.seasonsCount) out += '    seasonsCount: ' + m.seasonsCount + ',\n';
    if (m.startYear) out += '    startYear: ' + m.startYear + ',\n';
    if (m.endYear) out += "    endYear: '" + escapeDart(m.endYear) + "',\n";
    if (m.adaptationOrOriginal) out += "    adaptationOrOriginal: '" + escapeDart(m.adaptationOrOriginal) + "',\n";
    if (m.releaseMedium) out += "    releaseMedium: '" + escapeDart(m.releaseMedium) + "',\n";
  }
  out += '  ),\n';
}

out += '];\n\n';
out += 'List<Movie> getMoviesByIndustries(List<Industry> industries) {\n';
out += '  if (industries.isEmpty) return [];\n';
out += '  final set = industries.toSet();\n';
out += '  return kAllMovies.where((m) => set.contains(m.industry)).toList();\n';
out += '}\n';

const dir = path.join(projectRoot, 'flutter_app', 'lib', 'data');
if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
fs.writeFileSync(path.join(dir, 'movies_data.dart'), out, 'utf8');
console.log('Successfully generated movies_data.dart with', all.length, 'movies');
