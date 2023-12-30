import Topic "./topic";
import Principal "mo:base/Principal";

actor {

    stable let topic_store = Topic.init();
    let topic = Topic.use(topic_store);

    let operator = Principal.fromText("gffpl-zoaxl-xkuwi-llqyr-sjxmw-tvvc7-ei3vs-vxbno-zo5c5-v57d2-2qe");

    public shared({caller}) func create_topic(t: Topic.Doc): async () {
        assert(caller == operator);

        topic.db.insert(t);
    };

    public query func latest_topics(): async [Topic.Doc] {
      topic.createdAt.find(0, ^0, #bwd, 20);
    };

}