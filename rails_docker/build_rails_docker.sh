#/bin/sh
set -e

# Gemfile生成
echo 'source "https://rubygems.org"' > Gemfile
echo 'git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }' >> Gemfile
echo 'gem "rails"' >> Gemfile

# Gemfile.lock生成
touch Gemfile.lock

echo " ------------ START Build 1------------"
docker-compose build
echo " ------------ END Build 1------------"

# アプリの生成
echo "アプリのビルドを開始します。"
read -p "作成するアプリ名を入力してください：" AppName < /dev/tty

# Railsファイル構築開始
case ${AppName} in
  '')
    AppName=.;;
  *)
    echo " ------------ START Rails new ------------"
    docker-compose run web rails new ${AppName} --force --no-deps --database=postgresql 
    echo " ------------ END Rails new ------------"

    echo " ------------ START DB create ------------"
    sed -i -e 's/#host: localhost/host: db/' ${AppName}/config/database.yml
    SWAP_DB_FILE=${AppName}/config/database.yml-e
    if [[ -e $SWAP_DB_FILE ]]; then
       rm $SWAP_DB_FILE
    fi
     docker-compose run web rails db:create
    echo " ------------ END DB create ------------"
esac

# annotate 追加
echo 'gem "annotate"' >> Gemfile

echo " ------------ START Build 2------------"
docker-compose build
echo " ------------ END Build 2------------"
