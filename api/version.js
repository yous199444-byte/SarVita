export default function handler(_req, res) {
  res.status(200).json({
    agent: 'serverless',
    pkgVersion: '1.18.0',
    gitRevision: '39ccb6f1',
    gitBranch: 'main',
  });
}
