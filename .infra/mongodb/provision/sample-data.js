db = db.getSiblingDB("mydb")
db.posts.drop()
db.posts.insert({
    _id: ObjectId("507f191e810c19729de860ea"),
    title: "MongoDB Overview",
    description: "MongoDB is no sql database",
    by: "tinker point",
    url: "http://www.tinkerpoint.com",
    tags: ['mongodb', 'database', 'NoSQL'],
    likes: 100
})

db.posts.insert({
    _id: ObjectId("4701f918e10c19729de860ea"),
    title: "MySQL Overview",
    description: "MySQL is sql database",
    by: "tinker point",
    url: "http://www.tinkerpoint.com",
    tags: ['mysql', 'database', 'NoSQL'],
    likes: 1000
})

db.posts.insert({
    _id: ObjectId("7401f918e10c19729de860ea"),
    title: "Redis Overview",
    description: "Redis is nosql database",
    by: "tinker point",
    url: "http://www.tinkerpoint.com",
    tags: ['redis', 'database', 'NoSQL'],
    likes: 2000
})

db.posts.insert([
    {
        _id: ObjectId("7401f918e10c19729de86e0a"),
        title: "LaTeX Overview",
        description: "LaTeX is top typeset software",
        by: "tinker point",
        url: "http://www.tinkerpoint.com",
        tags: ['document', 'typeset', 'tool'],
        likes: 2000
    },
    {
        _id: ObjectId("740f19180e1c19729d8e60ea"),
        title: "Kubernetes Overview",
        description: "Kubernetes is a application deployment platform",
        by: "tinker point",
        url: "http://www.tinkerpoint.com",
        tags: ['container', 'infra', 'cloud'],
        likes: 2000
    },
    {
        _id: ObjectId("4710f918e10c19729de860ea"),
        title: "etcd Overview",
        description: "etcd is nosql database",
        by: "tinker point",
        url: "http://www.tinkerpoint.com",
        tags: ['etcd', 'database', 'NoSQL'],
        likes: 2000
    },
    {
        _id: ObjectId("74019f1e801c1972d9e860ea"),
        title: "Kafka Overview",
        description: "Kafka is message broker",
        by: "tinker point",
        url: "http://www.tinkerpoint.com",
        tags: ['mq', 'streaming', 'bigdata'],
        likes: 2000
    }
])

db.posts.insert([
    {
        title: "MongoDB Overview",
        description: "MongoDB is no SQL database",
        by: "tinker point",
        url: "http://www.tinkerpoint.com",
        tags: ["mongodb", "database", "NoSQL"],
        likes: 100
    },
    {
        title: "NoSQL Database",
        description: "NoSQL database doesn't have tables",
        by: "tinker point",
        url: "http://www.tinkerpoint.com",
        tags: ["mongodb", "database", "NoSQL"],
        likes: 20,
        comments: [
            {
                user: "user1",
                message: "My first comment",
                dateCreated: new Date(2013, 11, 10, 2, 35),
                like: 0
            }
        ]
    }
])

db.posts.aggregate([{ $group: { '_id': '$by', 'num_tutorial': { $sum: 1 } } }])
