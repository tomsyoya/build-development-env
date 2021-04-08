#/bin/sh
set -e

# Gemfile生成
echo 'source "https://rubygems.org"' > Gemfile
echo 'git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }' >> Gemfile
echo 'gem "rails"' >> Gemfile

# Gemfile.lock生成
touch Gemfile.lock

# アプリの生成
echo "アプリのビルドを開始します。"

# Railsファイル構築開始
echo " ------------ START Rails new ------------"
docker-compose run web rails new . --force --no-deps --api
echo " ------------ END Rails new ------------"

# annotate 追加
echo 'gem "annotate"' >> Gemfile

echo " ------------ START APP BUILD ------------"
docker-compose build
echo " ------------ END APP BUILD ------------"


# 当シェルをgit管理から除外
echo "build_rails_api_docker.sh" >> .gitignore

