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
docker-compose run web rails new . --force --no-deps --database=postgresql 
echo " ------------ END Rails new ------------"

# annotate 追加
echo 'gem "annotate"' >> Gemfile

echo " ------------ START APP BUILD ------------"
docker-compose build
echo " ------------ END APP BUILD ------------"

echo " ------------ START DB create ------------"
# develop環境にDB接続情報を設定
sed -i -e 's/#host: localhost/host: db/' ./config/database.yml
sed -i -e 's/#port: 5432/port: 5432/' ./config/database.yml
sed -i -e 's/#username: myapp/username: <%= ENV["DATABASE_USER"] %>/' ./config/database.yml
sed -i -e 's/#password:/password: <%= ENV["DATABASE_PASSWORD"] %>/' ./config/database.yml
# test環境にDB接続情報を設定
sed -i -e 's/database: myapp_test/database: myapp_test\n  host: db\n  username: <%= ENV["DATABASE_USER"] %>\n  password: <%= ENV["DATABASE_PASSWORD"] %>/' ./config/database.yml
SWAP_DB_FILE=./config/database.yml-e
if [[ -e $SWAP_DB_FILE ]]; then
   rm $SWAP_DB_FILE
fi
docker-compose run web rails db:create
echo " ------------ END DB create ------------"

# 当シェルをgit管理から除外
echo "build_rails_docker.sh" >> .gitignore

