import esbuild from 'esbuild'
import { replaceTscAliasPaths } from 'tsc-alias'

await esbuild.build({
	entryPoints: ['src/**/*'],
	outdir: 'dist',
	packages: 'external',
	format: 'esm'
})

await replaceTscAliasPaths({
	resolveFullExtension: '.js',
	resolveFullPaths: true,
	verbose: true
})