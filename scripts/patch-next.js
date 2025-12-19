const fs = require('fs');
const path = require('path');

const target = path.join(__dirname, '..', 'node_modules', 'next', 'package.json');
const patchedVersions = {
  'cross-spawn': '7.0.5',
  glob: '10.5.0',
};

function patch() {
  if (!fs.existsSync(target)) {
    console.log('Next package.json not found; skipping patch.');
    return;
  }

  const pkg = JSON.parse(fs.readFileSync(target, 'utf8'));
  let changed = false;

  ['dependencies', 'devDependencies'].forEach((section) => {
    if (!pkg[section]) return;
    for (const [dep, version] of Object.entries(patchedVersions)) {
      if (pkg[section][dep] && pkg[section][dep] !== version) {
        pkg[section][dep] = version;
        changed = true;
      }
    }
  });

  if (changed) {
    fs.writeFileSync(target, JSON.stringify(pkg, null, 2));
    console.log('Patched Next dependencies:', patchedVersions);
  } else {
    console.log('No patch needed; Next already uses patched versions or does not declare them.');
  }
}

patch();
