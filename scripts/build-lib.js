import webpack from 'webpack';
import fs from 'node:fs';
import path from 'node:path';
import getPublicLibConfig from '../webpack.config.js';

async function build() {
  console.log('Building public lib bundle...');
  const publicLibConfig = getPublicLibConfig({ forceDist: true, pruneCache: true });
  const compiler = webpack(publicLibConfig);

  compiler.run((err, stats) => {
    if (err) {
      console.error('Webpack compile error:', err);
      process.exit(1);
    }
    const info = stats.toJson();
    if (stats.hasErrors()) {
      console.error('Webpack compilation errors:\n', info.errors);
      process.exit(1);
    }
    if (stats.hasWarnings()) {
      console.warn('Webpack warnings:\n', info.warnings);
    }

    const outputPath = publicLibConfig.output.path;
    const outputFile = path.join(outputPath, publicLibConfig.output.filename);
    const destDir = path.join(process.cwd(), 'public');
    const destFile = path.join(destDir, 'lib.js');

    try {
      if (!fs.existsSync(outputFile)) {
        console.error('Expected output file not found:', outputFile);
        process.exit(1);
      }
      // Ensure dest dir exists
      if (!fs.existsSync(destDir)) fs.mkdirSync(destDir, { recursive: true });
      fs.copyFileSync(outputFile, destFile);
      console.log('Copied bundled lib to', destFile);
    } catch (copyErr) {
      console.error('Failed to copy bundled lib:', copyErr);
      process.exit(1);
    }

    compiler.close(() => {
      console.log('Webpack build finished successfully');
    });
  });
}

build();
