# 博客部署根目录
BLOGROOTPATH='/www/wwwroot/www.proger.cn/'

cd $BLOGROOTPATH
echo '清除代码>>>>>>>>>>>>>>>>'
# 删除代码
rm -rf progerchai.github.io

echo '开始拉取代码>>>>>>>>>>>>>>>>'
# git clone https://github.com/progerchai/progerchai.github.io.git

git clone https://github.com.cnpmjs.org/progerchai/progerchai.github.io.git

echo '拉取代码完成>>>>>>>>>>>>>>>>'
cd $BLOGROOTPATH/progerchai.github.io/site/

echo '开始搭建>>>>>>>>>>>>>>>>'
npm install
echo '开始部署>>>>>>>>>>>>>>>>'
npx hexo deploy --generate

echo '正在进行资源压缩>>>>>>>>>>>>>>>>'
npx gulp
# === hexo d -g

echo '运行完成>>>>>>>>>>>>>>>>'