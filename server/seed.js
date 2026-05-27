const db = require('./db');

const locations = [
  {
    name: '25教（计算机与信息科学学院）',
    latitude: 29.8285,
    longitude: 106.4255,
    radius: 50,
    description: '计算机与信息科学学院是西南大学重点学院之一，设有计算机科学与技术、软件工程、人工智能等多个本科专业。学院拥有博士点和硕士点，在人工智能、大数据、网络安全等领域具有较强的科研实力。',
    audio_url: '',
    image_url: ''
  },
  {
    name: '图书馆',
    latitude: 29.8275,
    longitude: 106.4245,
    radius: 60,
    description: '西南大学图书馆是西南地区最大的高校图书馆之一，藏书超过400万册。图书馆建筑宏伟，馆内设有多个阅览室、自习区和电子阅览区，是同学们学习和查阅资料的重要场所。',
    audio_url: '',
    image_url: ''
  },
  {
    name: '樟树林',
    latitude: 29.8270,
    longitude: 106.4250,
    radius: 40,
    description: '樟树林是西南大学最具标志性的自然景观之一，种植有大量香樟树，树龄多在50年以上。这里是同学们晨读、散步、休憩的好去处，四季常绿，空气清新，被誉为校园中最美的一片绿洲。',
    audio_url: '',
    image_url: ''
  },
  {
    name: '光华楼',
    latitude: 29.8280,
    longitude: 106.4260,
    radius: 50,
    description: '光华楼是西南大学的教学楼之一，以著名校友命名。楼内设有多间多媒体教室和实验室，是同学们日常上课的主要场所之一。建筑风格典雅，体现了西南大学深厚的历史底蕴。',
    audio_url: '',
    image_url: ''
  },
  {
    name: '行政楼',
    latitude: 29.8278,
    longitude: 106.4240,
    radius: 45,
    description: '行政楼是西南大学的行政管理中心，校领导办公室、教务处、学生处等重要行政部门均设在此处。建筑庄重大气，是校园行政运转的核心。',
    audio_url: '',
    image_url: ''
  },
  {
    name: '博物馆',
    latitude: 29.8265,
    longitude: 106.4255,
    radius: 50,
    description: '西南大学博物馆是一座综合性博物馆，收藏有大量历史文物、自然标本和艺术品。博物馆免费向师生和社会公众开放，是了解西南大学历史和文化的重要窗口。',
    audio_url: '',
    image_url: ''
  }
];

const insert = db.prepare(`
  INSERT OR IGNORE INTO locations (name, latitude, longitude, radius, description, audio_url, image_url)
  VALUES (@name, @latitude, @longitude, @radius, @description, @audio_url, @image_url)
`);

const seed = db.transaction(() => {
  for (const loc of locations) {
    insert.run(loc);
  }
});

seed();
console.log('景点数据初始化完成，共插入', locations.length, '个讲解点');
