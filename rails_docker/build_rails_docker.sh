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
    gem install bundler
fi

# Gemfile生成
bundle init

# gem railsのコメントを外す
sed -i -e 's/# gem "rails"/gem "rails"/' Gemfile

# Gemfile.lock生成
touch Gemfile.lock

#bundle install
bundle install --path=vendor/bundle