module AresMUSH
  module Api
    describe LoginCmdHandler do
      include ApiHandlerTestHelper
      
      let(:expected_cmd) { "login" }
      
      before do
        Global.api_router = ApiRouter.new(true)
        @char = Character.new
        @char.stub(:friends) { [] } 
        Character.stub(:find_by_name).with("Star") { @char }
        SpecHelpers.stub_translate_for_testing
      end
      
      it "should fail if the handle is not found" do
        Character.stub(:find_by_name).with("Star") { nil }
        cmd = ApiCommand.create_from("login @Star||ABC||Bob||public")
        response = Global.api_router.route_command(1, cmd)
        check_response(response, ApiResponse.error_status, "api.invalid_handle")
      end
      
      it "should fail if the handle is not linked to that char" do
        @char.linked_characters = {}
        cmd = ApiCommand.create_from("login @Star||ABC||Bob||public")
        response = Global.api_router.route_command(1, cmd)
        check_response(response, ApiResponse.error_status, "api.character_not_linked")
      end
      
      context "success" do
        before do
          @char.linked_characters = { "ABC" => {} }
          @time = Time.now
          Time.stub(:now) { @time }
          @char.should_receive(:save!) { }
        end
        
        it "should update the character's privacy, name and last login" do
          cmd = ApiCommand.create_from("login @Star||ABC||Bob||public")
          response = Global.api_router.route_command(1, cmd)
          check_response(response, ApiResponse.ok_status, "")
          @char.linked_characters.should include( { "ABC" => { "last_login" => @time, "name" => "Bob", "privacy" => "public" }})
        end
      
        it "should respond with the friends list as handles" do
          cmd = ApiCommand.create_from("login @Star||ABC||Bob||public")
          f1 = Character.new(name: "F1") 
          f2 = Character.new(name: "F2")
          @char.stub(:friends) { [ f1, f2 ]}
          response = Global.api_router.route_command(1, cmd)
          check_response(response, ApiResponse.ok_status, "@F1 @F2")
        end
      end
    end
  end
end