# 博客部署根目录
BLOGROOTPATH='/www/wwwroot/www.proger.cn/'


cd $BLOGROOTPATH

# git clone https://github.com/progerchai/progerchai.github.io.git

# git clone https://github.com.cnpmjs.org/progerchai/progerchai.github.io.git

# 判断是否已存在代码,若已存在则只需要pull即可

if [ -d "/progerchai.github.io/" ];then
  echo '未发现代码，重新拉取>>>>>>>>>>>>>>>>'
  git clone https://github.com/progerchai/progerchai.github.io.git
  else
  echo '开始拉取代码>>>>>>>>>>>>>>>>'
  git pull
fi

# 删除代码
# rm -rf progerchai.github.io

echo '拉取代码完成>>>>>>>>>>>>>>>>'
cd $BLOGROOTPATH/progerchai.github.io/site/

echo '开始搭建>>>>>>>>>>>>>>>>'
npm install
echo '开始部署>>>>>>>>>>>>>>>>'
npx hexo deploy --generate && npx gulp

# === hexo d -g

echo '运行完成>>>>>>>>>>>>>>>>'