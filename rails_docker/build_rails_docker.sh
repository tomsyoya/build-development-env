#/bin/sh
set -e

# rubyの存在チェック
if !(type "ruby" > /dev/null 2>&1); then
    echo "rubyがインストールされていません"
    exit 1
fi

# bundlerの存在チェック
if !(type "bundle" > /dev/null 2>&1); then
    echo "bundlerをインストールします。"
    echo " ------------ START install bundler ------------"
    gem install bundler
    echo " ------------ END install bundler ------------"
fi

# Gemfile生成
bundle init

# gem railsのコメントを外す
sed -i -e 's/# gem "rails"/gem "rails"/' Gemfile

# 不要なファイル削除
TMP_FILE="Gemfile-e" 
if [[ -e $TMP_FILE ]]; then
  echo "ファイルを削除します："$TMP_FILE
  rm $TMP_FILE
fi

# Gemfile.lock生成
touch Gemfile.lock

# bundle install
echo " ------------ START Generate Gem ------------"
bundle install --path=vendor/bundle
echo " ------------ END Generate Gem ------------"


echo "アプリのビルドを開始します。"
read -p "作成するアプリ名を入力してください：" AppName < /dev/tty

# Docker構築開始
case ${AppName} in
  *)
    echo "コンテナの生成を開始します"
    echo " ------------ START Rails new ------------"
    docker-compose run web rails new ${AppName} --force --no-deps --database=postgresql --skip-bundle
    echo " ------------ END Rails new ------------";;
esac

echo " ------------ START Build ------------"
docker-compose build
echo " ------------ END Build------------"
