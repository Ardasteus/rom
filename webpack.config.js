const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const TsconfigPathsPlugin = require('tsconfig-paths-webpack-plugin');
const DotenvPlugin = require('dotenv-webpack');

module.exports = {
	entry: "./src/index.tsx",
	resolve: {
		extensions: [".ts", ".tsx", ".js", ".json"],
		plugins: [new TsconfigPathsPlugin()]
	},
	output: {
		path: path.resolve(__dirname, "./dist"),
		filename: "bundle.js",
		publicPath: "/"
	},
	module: {
		rules: [{
			test: /\.ts|\.tsx$/,
			include: [
				path.resolve(__dirname, "./src")],
			loader: "awesome-typescript-loader",
		}]
	},
	devServer: {
		historyApiFallback: true
	},
	plugins: [
		new HtmlWebpackPlugin({
			template: "./public/index.html",
		}),
		new DotenvPlugin({
			path: './.env'
		})
	],
	devtool: "source-map",
	node: {
		fs: "empty"
	}
}