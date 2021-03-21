# 路径
BLOGPATH='.'

cd $BLOGPATH
echo '开始拉取代码>>>>>>>>>>>>>>>>'
git pull
echo '拉取代码完成>>>>>>>>>>>>>>>>'
cd $BLOGPATH/site/

echo '开始搭建>>>>>>>>>>>>>>>>'
npm install
echo '开始部署>>>>>>>>>>>>>>>>'
npx hexo deploy --generate
# === hexo d -g

echo '运行完成>>>>>>>>>>>>>>>>'