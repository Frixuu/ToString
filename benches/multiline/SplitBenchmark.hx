package;

import tostring.PrettyBuf;

using StringTools;

final class SplitBenchmark {
    static final DATA = "Lorem ipsum dolor sit amet, consectetur adipiscing elit.
    Donec consequat urna magna, ac ornare turpis rhoncus quis.
    Sed aliquam leo tincidunt, rhoncus ex vitae, viverra dolor.
    Sed lacinia cursus dolor, ut mattis nulla iaculis eu.
    Etiam aliquam nunc sit amet felis tristique molestie.
    Quisque quis pretium neque. Integer et neque urna.
    Integer finibus ut leo eu placerat.
    Nulla purus massa, feugiat ut arcu eget, efficitur commodo eros
    Maecenas egestas lectus quis consequat gravida.
    Nulla lacinia, nulla quis ornare vestibulum,
    sapien nibh sagittis libero, vel efficitur lectus elit nec elit.
    Maecenas dapibus risus vel libero luctus, non lobortis eros pellentesque.
    Phasellus a sodales enim. Aenean consequat, arcu ut sodales mollis,
    tellus mi maximus lorem, a ornare nibh purus sed orci.

    Etiam porttitor erat ac finibus porta. Proin in accumsan libero, eu semper elit.
    Proin tempor hendrerit elit sit amet ultricies.
    Nullam lorem dolor, fermentum vel elit sed, suscipit suscipit ex.
    Donec elit lacus, molestie quis interdum vestibulum, imperdiet vel quam.
    Donec augue neque, sollicitudin at bibendum eget, faucibus eu nulla.
    Nullam sit amet lacus tempor, mollis eros quis, pulvinar libero.
    Nunc non nibh nec mi porttitor auctor et porta nulla.
    In quis urna augue. Pellentesque in diam metus. Integer tincidunt aliquam tempus.
    Nam aliquam massa eget ullamcorper pretium.
    Duis ornare magna sem, nec finibus lectus condimentum at.
    Mauris auctor blandit eros et scelerisque.
    Aliquam ut odio varius, maximus ante auctor, convallis tortor.";

    public function new() {}

    public function multilineWithDelimiter(): PrettyBuf {
        final buf = new PrettyBuf();
        buf.addMultilineWithDelimiter(DATA, "\r\n");
        return buf;
    }

    public function multiline(): PrettyBuf {
        final buf = new PrettyBuf();
        @:privateAccess buf.addMultilineDefaultImpl(DATA);
        return buf;
    }

    #if js
    public function multilineJs(): PrettyBuf {
        final buf = new PrettyBuf();
        @:privateAccess buf.addMultilineJsImpl(DATA);
        return buf;
    }
    #end
}
