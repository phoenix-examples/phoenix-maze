
defmodule Mix.Tasks.Install do

    def run(_) do
        Amnesia.Schema.create
     
        Amnesia.start
     
        Database.create(disk: [node])
     
        # This waits for the database to be fully created.
        Database.wait
     
        # Stop mnesia so it can flush everything and keep the data sane.
        Amnesia.stop
    end

end

