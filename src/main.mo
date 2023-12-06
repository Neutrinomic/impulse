import Topic "./topic";
import Principal "mo:base/Principal";

actor {

    stable let topic_store = Topic.init();
    let topic = Topic.use(topic_store);

    public shared({caller}) func create_topic(t: Topic.Doc): async () {
        assert(Principal.isController(caller));

        topic.db.insert(t);
    };

    public query func latest_topics(): async [Topic.Doc] {
      topic.createdAt.find(0, ^0, #bwd, 20);
    };

}