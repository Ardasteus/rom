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
		rules: [
			{
				test: /\.ts|\.tsx$/,
				include: [
					path.resolve(__dirname, "./src")],
				loader: "awesome-typescript-loader",
			}, {
				test: /\.(png|jpe?g|gif)$/,
				use: [
					{
						loader: 'file-loader',
						options: {},
					},
				],
			},
			{
				test: /\.scss$/,
				use: [{
					loader: "style-loader"
				}, {
					loader: "css-loader"
				}, {
					loader: "sass-loader",
					options: {
						includePaths: ["absolute/path/a", "absolute/path/b"]
					}
				}]
			}
		]
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