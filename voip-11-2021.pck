GDPC                                                                                H   res://.import/VoiceInstance.svg-56fbd7fa19d2e57deeeef52ce13ce7ac.stex   �E      ?      ��;;��Vt���ї^EL   res://.import/VoiceOrchestrator.svg-1a02a4ff0ae9a89021ae13701008c299.stex   �J      &      P�.B"ò�W�{�<   res://.import/icon.png-487276ed1e3a0c39cad0279d744ee560.stex�r      J>      �_�H�3�R�4�\)R<   res://.import/icon.svg-218a8f2b3041327d8a5756f3a245f83b.stexP�      �A      E��<��T��N	(   res://addons/godot-voip/demo/Demo.tscn  p      :      �Κ���v��׭A��0   res://addons/godot-voip/demo/Network.gd.remap   ��      9       ��Wo�k'z�].U�R�(   res://addons/godot-voip/demo/Network.gdc�A            Un��7���v�&΅d��8   res://addons/godot-voip/icons/VoiceInstance.svg.import  �G      �      |/��.���Kr���5:�<   res://addons/godot-voip/icons/VoiceOrchestrator.svg.import  �L      �      �N/���Ϟ}P�V��_(   res://addons/godot-voip/plugin.gd.remap ��      3       �|QV�"��vi+�ʈ$   res://addons/godot-voip/plugin.gdc  �O      �      E^x[a���uQfu�8   res://addons/godot-voip/scripts/voice_instance.gd.remap  �      C       >�N��d��5�����4   res://addons/godot-voip/scripts/voice_instance.gdc  �R      7      7���'�ЁQ�@��&4   res://addons/godot-voip/scripts/voice_mic.gd.remap  P�      >       �:eփ�瓑�0�u�0   res://addons/godot-voip/scripts/voice_mic.gdc   �`      K      @��'�Ń4���4>��L<   res://addons/godot-voip/scripts/voice_orchestrator.gd.remap ��      G       ����յߩ'<��f8   res://addons/godot-voip/scripts/voice_orchestrator.gdc   d      �      3P��1��ӕ�A���   res://default_env.tres  �q      �       um�`�N��<*ỳ�8   res://icon.png  ��      J3      Z��`z;Cs��L��   res://icon.png.import   а      �      �����%��(#AB�   res://icon.svg.import    �      �      ͹�����U~�E�=��   res://project.binary0,     �      鲢
~n�B�T�r�c_    [gd_scene load_steps=5 format=2]

[ext_resource path="res://addons/godot-voip/scripts/voice_orchestrator.gd" type="Script" id=1]
[ext_resource path="res://addons/godot-voip/demo/Network.gd" type="Script" id=2]
[ext_resource path="res://icon.svg" type="Texture" id=3]

[sub_resource type="GDScript" id=1]
script/source = "extends Control

onready var buttonServer: Button = $MarginContainer/HBoxContainer/VBoxContainer/Server
onready var buttonClient: Button = $MarginContainer/HBoxContainer/VBoxContainer/Client
onready var buttonVoice : Button = $MarginContainer/HBoxContainer/VBoxContainer/Voice
onready var buttonDisconnect : Button = $MarginContainer/HBoxContainer/VBoxContainer/Disconnect

onready var spinBoxHostPort: SpinBox = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer2/Port
onready var lineEditClientIp: LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer1/Ip
onready var spinBoxClientPort: SpinBox = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer3/Port
onready var checkboxListen: CheckBox = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer4/Listen
onready var checkBoxToggle: CheckBox = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer4/Toggle
onready var sliderInputThreshold: HSlider = $MarginContainer/HBoxContainer/VBoxContainer/InputThreshold

onready var labelStatus: Label = $MarginContainer/HBoxContainer/VBoxContainer2/HBoxContainer/Status
onready var labelLog: RichTextLabel = $MarginContainer/HBoxContainer/VBoxContainer2/Log
onready var spinBoxInputThreshold: SpinBox = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Value

onready var voice: VoiceOrchestrator = $VoiceOrchestrator
onready var network: Network = $Network

func _ready() -> void:
	voice.connect(\"received_voice_data\", self, \"_received_voice_data\")
	voice.connect(\"sent_voice_data\", self, \"_sent_voice_data\")

	get_tree().connect(\"connected_to_server\", self, \"_connected_ok\")
	get_tree().connect(\"server_disconnected\", self, \"_server_disconnected\")
	get_tree().connect(\"connection_failed\", self, \"_connected_fail\")

	get_tree().connect(\"network_peer_connected\", self, \"_player_connected\")
	get_tree().connect(\"network_peer_disconnected\", self, \"_player_disconnected\")

	if voice.recording:
		checkBoxToggle.pressed = true
		buttonVoice.pressed = true

	spinBoxHostPort.value = network.server_port
	lineEditClientIp.text = network.server_ip
	spinBoxClientPort.value = network.server_port
	checkboxListen.pressed = voice.listen
	checkBoxToggle.pressed = buttonVoice.toggle_mode
	sliderInputThreshold.value = voice.input_threshold

func _on_Button_server_pressed() -> void:
	var err = network.start_server()
	if err != OK:
		labelStatus.text = \"Failed to create server! Error: %s\" % err

		if err == FAILED && OS.get_name() == \"HTML5\":
			labelStatus.text += \", Starting a server is not supported on HTML5.\"

		return

	labelStatus.text = \"server started\"

	ui_transition()

func _on_Button_client_pressed() -> void:
	var err = network.start_client()
	if err != OK:
		labelStatus.text = \"Failed to create client! Error: %s\" % err
		return

	labelStatus.text = \"Connecting...\"

func _on_Disconnect_pressed() -> void:
	network.stop()
	ui_reset()

func _on_Button_voice_button_down() -> void:
	if !buttonVoice.toggle_mode:
		voice.recording = true

func _on_Button_voice_button_up() -> void:
	if !buttonVoice.toggle_mode:
		voice.recording = false

func _on_Voice_toggled(button_pressed: bool) -> void:
	voice.recording = button_pressed

func _on_Toggle_toggled(button_pressed: bool) -> void:
	buttonVoice.toggle_mode = button_pressed

func _on_Listen_toggled(button_pressed: bool) -> void:
	voice.listen = button_pressed

func _on_InputThreshold_value_changed(value: float) -> void:
	voice.input_threshold = value
	spinBoxInputThreshold.value = value

func _on_Value_value_changed(value: float) -> void:
	sliderInputThreshold.value = value

func _on_Port_value_changed(value: float) -> void:
	network.server_port = int(value)

func _on_Ip_text_changed(new_text: String) -> void:
	network.server_ip = new_text

func _connected_ok() -> void:
	labelStatus.text = \"Connected ok\"
	ui_transition()

func _connected_fail() -> void:
	labelStatus.text = \"Failed to connect to server!\"
	ui_reset()

func _server_disconnected() -> void:
	labelStatus.text = \"Server disconnected\"
	ui_reset()

func _player_connected(_id: int) -> void:
	labelLog.text += \"Player with id: %s connected\\n\" % _id

func _player_disconnected(_id: int) -> void:
	labelLog.text += \"Player with id: %s disconnected\\n\" % _id

func _received_voice_data(data: PoolRealArray, id: int) -> void:
	labelLog.add_text(\"received voice data of size:%s from id:%s\\n\" % [data.size(), id])

func _sent_voice_data(data: PoolRealArray) -> void:
	labelLog.add_text(\"sent voice data of size:%s\\n\" % data.size())


func ui_transition() -> void:
	buttonServer.disabled = true
	buttonClient.disabled = true
	buttonVoice.disabled = false
	buttonDisconnect.disabled = false
	checkboxListen.disabled = false
	checkBoxToggle.disabled = false
	sliderInputThreshold.editable = true
	spinBoxInputThreshold.editable = true
	spinBoxHostPort.editable = false
	lineEditClientIp.editable = false
	spinBoxClientPort.editable = false

func ui_reset() -> void:
	buttonServer.disabled = false
	buttonClient.disabled = false
	buttonVoice.disabled = true
	buttonDisconnect.disabled = true
	checkboxListen.disabled = true
	checkBoxToggle.disabled = false
	buttonVoice.pressed = false
	sliderInputThreshold.editable = false
	spinBoxInputThreshold.editable = false
	spinBoxHostPort.editable = true
	lineEditClientIp.editable = true
	spinBoxClientPort.editable = true
"

[node name="Demo" type="Control"]
anchor_right = 1.0
anchor_bottom = 1.0
script = SubResource( 1 )
__meta__ = {
"_edit_use_anchors_": false
}

[node name="Network" type="Node" parent="."]
script = ExtResource( 2 )

[node name="VoiceOrchestrator" type="Node" parent="."]
script = ExtResource( 1 )

[node name="MarginContainer" type="MarginContainer" parent="."]
anchor_right = 1.0
anchor_bottom = 1.0
custom_constants/margin_right = 50
custom_constants/margin_top = 50
custom_constants/margin_left = 50
custom_constants/margin_bottom = 50
__meta__ = {
"_edit_use_anchors_": false
}

[node name="HBoxContainer" type="HBoxContainer" parent="MarginContainer"]
margin_left = 50.0
margin_top = 50.0
margin_right = 974.0
margin_bottom = 550.0
custom_constants/separation = 50
__meta__ = {
"_edit_use_anchors_": false
}

[node name="VBoxContainer" type="VBoxContainer" parent="MarginContainer/HBoxContainer"]
margin_right = 250.0
margin_bottom = 500.0
rect_min_size = Vector2( 250, 0 )
custom_constants/separation = 10
__meta__ = {
"_edit_use_anchors_": false
}

[node name="Server" type="Button" parent="MarginContainer/HBoxContainer/VBoxContainer"]
margin_right = 250.0
margin_bottom = 20.0
text = "Start server"
__meta__ = {
"_edit_use_anchors_": false
}

[node name="HBoxContainer2" type="HBoxContainer" parent="MarginContainer/HBoxContainer/VBoxContainer"]
margin_top = 30.0
margin_right = 250.0
margin_bottom = 54.0
__meta__ = {
"_edit_use_anchors_": false
}

[node name="Label" type="Label" parent="MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer2"]
margin_top = 5.0
margin_right = 64.0
margin_bottom = 19.0
text = "Host port:"
__meta__ = {
"_edit_use_anchors_": false
}

[node name="Port" type="SpinBox" parent="MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer2"]
margin_left = 68.0
margin_right = 250.0
margin_bottom = 24.0
size_flags_horizontal = 3
max_value = 65535.0
rounded = true
__meta__ = {
"_edit_use_anchors_": false
}

[node name="HSeparator" type="HSeparator" parent="MarginContainer/HBoxContainer/VBoxContainer"]
margin_top = 64.0
margin_right = 250.0
margin_bottom = 68.0

[node name="Client" type="Button" parent="MarginContainer/HBoxContainer/VBoxContainer"]
margin_top = 78.0
margin_right = 250.0
margin_bottom = 98.0
text = "Start client"
__meta__ = {
"_edit_use_anchors_": false
}

[node name="HBoxContainer1" type="HBoxContainer" parent="MarginContainer/HBoxContainer/VBoxContainer"]
margin_top = 108.0
margin_right = 250.0
margin_bottom = 132.0

[node name="Label2" type="Label" parent="MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer1"]
margin_top = 5.0
margin_right = 60.0
margin_bottom = 19.0
text = "Server ip:"
__meta__ = {
"_edit_use_anchors_": false
}

[node name="Ip" type="LineEdit" parent="MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer1"]
margin_left = 64.0
margin_right = 250.0
margin_bottom = 24.0
size_flags_horizontal = 3
text = "127.0.0.1"

[node name="HBoxContainer3" type="HBoxContainer" parent="MarginContainer/HBoxContainer/VBoxContainer"]
margin_top = 142.0
margin_right = 250.0
margin_bottom = 166.0

[node name="Label2" type="Label" parent="MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer3"]
margin_top = 5.0
margin_right = 74.0
margin_bottom = 19.0
text = "Server port:"
__meta__ = {
"_edit_use_anchors_": false
}

[node name="Port" type="SpinBox" parent="MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer3"]
margin_left = 78.0
margin_right = 250.0
margin_bottom = 24.0
size_flags_horizontal = 3
max_value = 65535.0
rounded = true
__meta__ = {
"_edit_use_anchors_": false
}

[node name="HSeparator2" type="HSeparator" parent="MarginContainer/HBoxContainer/VBoxContainer"]
margin_top = 176.0
margin_right = 250.0
margin_bottom = 180.0

[node name="HBoxContainer" type="HBoxContainer" parent="MarginContainer/HBoxContainer/VBoxContainer"]
margin_top = 190.0
margin_right = 250.0
margin_bottom = 214.0

[node name="Label" type="Label" parent="MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer"]
margin_top = 5.0
margin_right = 103.0
margin_bottom = 19.0
text = "Input threshold:"
__meta__ = {
"_edit_use_anchors_": false
}

[node name="Value" type="SpinBox" parent="MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer"]
margin_left = 107.0
margin_right = 250.0
margin_bottom = 24.0
size_flags_horizontal = 3
max_value = 1.0
step = 0.0
editable = false

[node name="InputThreshold" type="HSlider" parent="MarginContainer/HBoxContainer/VBoxContainer"]
margin_top = 224.0
margin_right = 250.0
margin_bottom = 240.0
max_value = 0.1
step = 0.0
allow_greater = true
allow_lesser = true
editable = false
ticks_on_borders = true

[node name="HBoxContainer4" type="HBoxContainer" parent="MarginContainer/HBoxContainer/VBoxContainer"]
margin_top = 250.0
margin_right = 250.0
margin_bottom = 274.0
__meta__ = {
"_edit_use_anchors_": false
}

[node name="Listen" type="CheckBox" parent="MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer4"]
margin_right = 123.0
margin_bottom = 24.0
size_flags_horizontal = 3
disabled = true
text = "Listen"
__meta__ = {
"_edit_use_anchors_": false
}

[node name="Toggle" type="CheckBox" parent="MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer4"]
margin_left = 127.0
margin_right = 250.0
margin_bottom = 24.0
size_flags_horizontal = 3
disabled = true
text = "Toggle"
__meta__ = {
"_edit_use_anchors_": false
}

[node name="Voice" type="Button" parent="MarginContainer/HBoxContainer/VBoxContainer"]
margin_top = 284.0
margin_right = 250.0
margin_bottom = 304.0
disabled = true
text = "Speak"
__meta__ = {
"_edit_use_anchors_": false
}

[node name="Disconnect" type="Button" parent="MarginContainer/HBoxContainer/VBoxContainer"]
margin_top = 314.0
margin_right = 250.0
margin_bottom = 334.0
disabled = true
text = "Disconnect"
__meta__ = {
"_edit_use_anchors_": false
}

[node name="CenterContainer" type="CenterContainer" parent="MarginContainer/HBoxContainer/VBoxContainer"]
margin_top = 344.0
margin_right = 250.0
margin_bottom = 500.0
size_flags_horizontal = 3
size_flags_vertical = 3
__meta__ = {
"_edit_use_anchors_": false
}

[node name="TextureRect" type="TextureRect" parent="MarginContainer/HBoxContainer/VBoxContainer/CenterContainer"]
margin_left = 50.0
margin_top = 3.0
margin_right = 200.0
margin_bottom = 153.0
rect_min_size = Vector2( 150, 150 )
texture = ExtResource( 3 )
expand = true
stretch_mode = 5

[node name="VBoxContainer2" type="VBoxContainer" parent="MarginContainer/HBoxContainer"]
margin_left = 300.0
margin_right = 924.0
margin_bottom = 500.0
size_flags_horizontal = 3
size_flags_vertical = 3

[node name="HBoxContainer" type="HBoxContainer" parent="MarginContainer/HBoxContainer/VBoxContainer2"]
margin_right = 624.0
margin_bottom = 14.0

[node name="Label" type="Label" parent="MarginContainer/HBoxContainer/VBoxContainer2/HBoxContainer"]
margin_right = 43.0
margin_bottom = 14.0
text = "Status:"
__meta__ = {
"_edit_use_anchors_": false
}

[node name="Status" type="Label" parent="MarginContainer/HBoxContainer/VBoxContainer2/HBoxContainer"]
margin_left = 47.0
margin_right = 47.0
margin_bottom = 14.0
__meta__ = {
"_edit_use_anchors_": false
}

[node name="Log" type="RichTextLabel" parent="MarginContainer/HBoxContainer/VBoxContainer2"]
margin_top = 18.0
margin_right = 624.0
margin_bottom = 500.0
focus_mode = 2
size_flags_vertical = 3
scroll_following = true
selection_enabled = true

[connection signal="pressed" from="MarginContainer/HBoxContainer/VBoxContainer/Server" to="." method="_on_Button_server_pressed"]
[connection signal="value_changed" from="MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer2/Port" to="." method="_on_Port_value_changed"]
[connection signal="pressed" from="MarginContainer/HBoxContainer/VBoxContainer/Client" to="." method="_on_Button_client_pressed"]
[connection signal="text_changed" from="MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer1/Ip" to="." method="_on_Ip_text_changed"]
[connection signal="value_changed" from="MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer3/Port" to="." method="_on_Port_value_changed"]
[connection signal="value_changed" from="MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Value" to="." method="_on_Value_value_changed"]
[connection signal="value_changed" from="MarginContainer/HBoxContainer/VBoxContainer/InputThreshold" to="." method="_on_InputThreshold_value_changed"]
[connection signal="toggled" from="MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer4/Listen" to="." method="_on_Listen_toggled"]
[connection signal="toggled" from="MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer4/Toggle" to="." method="_on_Toggle_toggled"]
[connection signal="button_down" from="MarginContainer/HBoxContainer/VBoxContainer/Voice" to="." method="_on_Button_voice_button_down"]
[connection signal="button_up" from="MarginContainer/HBoxContainer/VBoxContainer/Voice" to="." method="_on_Button_voice_button_up"]
[connection signal="toggled" from="MarginContainer/HBoxContainer/VBoxContainer/Voice" to="." method="_on_Voice_toggled"]
[connection signal="pressed" from="MarginContainer/HBoxContainer/VBoxContainer/Disconnect" to="." method="_on_Disconnect_pressed"]
             GDSC         %   �      ���Ӷ���   ������ݶ   ����������¶   ��������ƶ��   �����������¶���   ���Ķ���   ������������涶�   ����   ��Ķ   ��������������¶   ����   �����������Ķ���   ���������Ķ�   �����ض�   ���ƶ���   �������Ӷ���   �����������Ķ���   ��������������¶   �������������������¶���   ��������������Ķ   �        192.168.1.1                                                      %   	   &   
   3      9      <      =      >      ?      B      C      K      U      V      c      d      j      m      n      o      p      s      t      |      �       �   !   �   "   �   #   �   $   �   %   3Y2�  YY;�  VY;�  V�  YY0�  PQX�  V�  ;�  V�  T�  PQY�  ;�  V�  T�	  P�  R�  Q�  &�  �
  V�  .�  Y�  Y�  .�
  YY0�  PQX�  V�  ;�  V�  T�  PQY�  ;�  V�  T�  P�  R�  QY�  &�  �
  V�  .�  Y�  Y�  .�
  YY0�  PQX=V�  &�  PQT�  �  V�  &�  PQT�  4�  V�  �  PQT�  T�  PQ�  '�  PQT�  4�  V�  �  PQT�  T�  PQYY`GDST              #  PNG �PNG

   IHDR         ��a   sRGB ���  �IDAT8�u��kA��Ѥ�nbD!*��ū)Ճ����?���,�AD�R�'=i@�A<H^�A*?�P($Q�%�ݙ�L��sx��=��;�x������+Q�M)�u��|�6}	��- � �\�B\Գe�{!Dc�jĂs�p%�����\�.���I�Q��E�T
q�$�F٘Z.J�|�x�}���Tmb���3��U hVޮ&����`8=6�r��U�>�{�W�%�x���Շ�맥[��4 @	B����?��̀�*�Ձ9 @LKY�>�i�y�^��b�'�m'���q���8��Y�SZ�`�7H:��QE������<��:���C�T#��ww���9D(d�Q����w�}��v�uQ�n]�t:2P�[owZ5����n߫�	��B�!���{`q �5���n��I%�gG3pt��灭��D4�(��v�`������r���    IEND�B`� [remap]

importer="texture"
type="StreamTexture"
path="res://.import/VoiceInstance.svg-56fbd7fa19d2e57deeeef52ce13ce7ac.stex"
metadata={
"vram_texture": false
}

[deps]

source_file="res://addons/godot-voip/icons/VoiceInstance.svg"
dest_files=[ "res://.import/VoiceInstance.svg-56fbd7fa19d2e57deeeef52ce13ce7ac.stex" ]

[params]

compress/mode=0
compress/lossy_quality=0.7
compress/hdr_mode=0
compress/bptc_ldr=0
compress/normal_map=0
flags/repeat=0
flags/filter=true
flags/mipmaps=false
flags/anisotropic=false
flags/srgb=2
process/fix_alpha_border=true
process/premult_alpha=false
process/HDR_as_SRGB=false
process/invert_color=false
stream=false
size_limit=0
detect_3d=true
svg/scale=1.0
             GDST              
  PNG �PNG

   IHDR         ��a   sRGB ���  �IDAT8���?hSQ���y�>�V���Ҹ��N:u/���[�.�8]
�&]���� �*b�.B�,��D���b���'h|�������Å{W.��F �Dy���ԾqT��Q��z�;s�'`���'T�5�S�5`X6�,�ݨ�����G"fzWT^UU����D��$�1��� ;���Of9����c�̑��qU��c��s���6ݹk��w+���a��jH>ҁ��&}�[�TÀ��Bwn���g:k����ۡ�ı��c��Yn/R���@i�D#�����g;�4.��'fb�$[��~�"�a�ɏ h�a�1�|��{WN>Q�{� ��0���&w�ٴ{&�%��n�蚭ͳ�t�����xĎGl{�o�zR�=��G���������Q�{��cw:��<����z��� P�My3ꎖݶ�ӌ�u��3}AS1ͯ�    IEND�B`�          [remap]

importer="texture"
type="StreamTexture"
path="res://.import/VoiceOrchestrator.svg-1a02a4ff0ae9a89021ae13701008c299.stex"
metadata={
"vram_texture": false
}

[deps]

source_file="res://addons/godot-voip/icons/VoiceOrchestrator.svg"
dest_files=[ "res://.import/VoiceOrchestrator.svg-1a02a4ff0ae9a89021ae13701008c299.stex" ]

[params]

compress/mode=0
compress/lossy_quality=0.7
compress/hdr_mode=0
compress/bptc_ldr=0
compress/normal_map=0
flags/repeat=0
flags/filter=true
flags/mipmaps=false
flags/anisotropic=false
flags/srgb=2
process/fix_alpha_border=true
process/premult_alpha=false
process/HDR_as_SRGB=false
process/invert_color=false
stream=false
size_limit=0
detect_3d=true
svg/scale=1.0
 GDSC            O      �����������ض���   ����������Ӷ   ��������������Ӷ   ���������Ӷ�   �����������������Ӷ�      VoiceInstance         Node   1   res://addons/godot-voip/scripts/voice_instance.gd      /   res://addons/godot-voip/icons/VoiceInstance.svg       VoiceOrchestrator      5   res://addons/godot-voip/scripts/voice_orchestrator.gd      3   res://addons/godot-voip/icons/VoiceOrchestrator.svg                                                     	   !   
   #      $      '      *      -      3      8      :      ;      C      H      M      6Y3YY0�  PQX=V�  �  P�  R�  �  R�  ?P�  QR�  ?P�  Q�  QY�  �  P�  �  R�  �  R�  ?P�  QR�  ?P�  Q�  QYY0�  PQX=V�  �  PQ�  �  P�  QY`     GDSC   B      j   j     ���Ӷ���   ������������Ӷ��   ������������������׶   ��������������׶$   �������������������������������Ķ���   ��������Ѷ��   �����ض�   ��������������Ҷ   ���ն���   �������ն���   �����Ӷ�   ��������������Ӷ   �����������������Ӷ�   ��������ݶ��    ���������������������������ݶ���   ��������������Ķ   ��������������������Ѷ��   �������Ŷ���   ����׶��   �������������Ӷ�   �����������ն���   ����������ն   ����   ��������Ҷ��   �������������ζ�   ����������Ķ   ������������ζ��   ��Ŷ   �������������¶�   ������������Ӷ��   �������϶���   �����Ķ�   �������Ӷ���   ����������������Ķ��   ����������������Ą�   ����������������ą�   ��������Ķ��   �������������������Ķ���   ������������޶��   �����۶�   ������������������ݶ   ���϶���   �����ݶ�   ����������׶   �Ҷ�   ����������ڶ   �����������϶���   �������������������Ӷ���   ߶��   ���Ӷ���   ���������Ӷ�   �����Ӷ�   �����Ķ�   �����Ӷ�   ����������Ķ   �����������Ķ���   ����������׶   ���������Ķ�   ���׶���   ��������Ӷ��   ����Ӷ��   ζ��   ϶��   �������Ӷ���   ��������������������Ҷ��   �������������Ӷ�                   �?  {�G�zt?              /   node:'%s' is not any kind of AudioStreamPlayer!       node:'%s' does not exist!     �������?      received_voice_data             @      _speak        sent_voice_data                          	                           	   #   
   1      2      7      :      ?      D      L      Q      R      ]      c      g      h      l      m      s      {      �      �      �      �      �       �   !   �   "   �   #   �   $   �   %   �   &   �   '   �   (   �   )   �   *   �   +   �   ,   �   -   �   .   �   /     0     1     2     3     4   !  5   '  6   +  7   ,  8   5  9   6  :   =  ;   >  <   D  =   N  >   P  ?   Q  @   g  A   y  B   �  C   �  D   �  E   �  F   �  G   �  H   �  I   �  J   �  K   �  L   �  M   �  N   �  O   �  P   �  Q   �  R   �  S   �  T   �  U   �  V   �  W   �  X     Y     Z   '  [   .  \   4  ]   6  ^   7  _   ;  `   H  a   I  b   X  c   _  d   `  e   d  f   e  g   f  h   g  i   h  j   3Y2�  YYB�  YB�  YY8;�  V�  Y8;�  V�  Y8;�  V�  Y8P�  R�  R�  Q;�  V�  YY;�  V�	  Y;�
  Y;�  V�  Y;�  V�  Y;�  V�  PQY;�  YY0�  P�  V�  QX=V�  &�  �  V�  �  PQY�  �  PQYY0�  PQV�  �  �	  T�  PQ�  �  P�  Q�  ;�  V�  T�  P�  T�  Q�  �  �  T�  P�  R�  QYY0�  PQV�  &�  T�  PQV�  ;�  �   P�  Q�  &�  �  V�  &�  4�!  �  4�"  �  4�#  V�  �
  �  �  (V�  �E  P�  �  Q�  (V�  �E  P�  �  Q�  (V�  �
  �!  T�  PQ�  �  P�
  QY�  ;�$  V�%  T�  PQ�  �$  T�&  �  �  �
  T�'  �$  Y�  �  �
  T�(  PQ�  �
  T�)  PQYYD0�*  P�+  V�  R�,  V�  QV�  &�  �  V�  �  PQY�  �-  P�	  R�+  R�,  QY�  �  T�.  P�+  QYY0�  PQV�  &�  T�/  PQ	�
  V�  .Y�  )�0  �K  P�4  P�  T�/  PQR�  T�1  PQQQV�  �  T�2  P�  P�  L�  MR�  L�  MQQ�  �  T�3  P�  QY�  &�  T�/  PQ�  V�  ;�4  �  PQ�  �4  T�5  P�  T�/  PQQ�  �  T�6  P�4  QYY0�  PQV�  &�  V�  &�  �  V�  �  PQY�  &�  V�  �  T�7  PQY�  ;�8  V�  �  T�9  P�  T�/  PQQ�  &�8  T�1  PQ�  VY�  ;�:  �  PQ�  �:  T�5  P�8  T�1  PQQY�  ;�;  V�  �  )�0  �K  P�8  T�1  PQQV�  ;�<  VP�8  L�0  MT�=  �8  L�0  MT�>  Q�  �  �;  �3  P�<  R�;  Q�  �:  L�0  M�<  �  &�;  	�  V�  .Y�  &�  V�  �*  P�:  R�?  PQT�@  PQQY�  �A  P�  R�:  R�?  PQT�@  PQQ�  �-  P�  R�:  QY�  �  �  YYYYY`         GDSC            w      ����������������Ķ��   �������ն���   �����϶�   �������������Ķ�   ����������Ķ   ������������ζ��   �������Ӷ���   ��ζ   ��������¶��   ������Ŷ   �����������Ӷ���   �������������¶�   �����������������Ӷ�   ����   �����������Ӷ���   ��Ŷ   �����۶�   ��������������������Ӷ��   ���϶���             VoiceMicRecorder                                                 $      (      )   	   3   
   :      ;      B      K      L      Y      Z      c      d      h      i      q      u      3Y2�  YY0�  PQX=V�  ;�  �  *�  T�  P�  �>  P�  QQ�  V�  �  �  Y�  ;�  �  �>  P�  Q�  ;�  �  T�  Y�  �  T�	  P�  Q�  �  T�
  P�  R�  QY�  �  T�  P�  R�  T�  PQQY�  �  T�  P�  R�  QY�  �  �  Y�  �  �  T�  PQ�  �  PQY`     GDSC   +      k   �     ���Ӷ���   ����������������Ķ��   ������������������׶   ��������������׶   ���������������Ӷ���   ���������������Ӷ���   ��������Ѷ��   �������������Ѷ�   �����ض�   ����������ض   ��������������Ҷ   �������������������Ҷ���   ��������Ŷ��   ��Ҷ   �����϶�   �������Ӷ���   ������¶   ���������������Ŷ���   ����׶��   ���������������Ķ���   ����������������Ķ��   ���������������Ӷ���   ��������������������Ҷ��   �����¶�   �Ҷ�   �������Ӷ���   ������������Ӷ��   ����   ���Ӷ���   ��������Ҷ��   ����������ڶ   ���������������Ӷ���   ���������Ӷ�   ����Ӷ��   ���Ŷ���   ����Ӷ��   ������������ݶ��   �������������������Ҷ���   ����������������Ҷ��   �������������������Ҷ���   �������������������׶���   ���׶���   ���������������׶���                   �?  {�G�zt?          connected_to_server       _connected_ok         server_disconnected       _server_disconnected      connection_failed         network_peer_connected        _player_connected         network_peer_disconnected         _player_disconnected            sent_voice_data       _sent_voice_data      received_voice_data       _received_voice_data      created_instance      removed_instance                         	                           	      
   '      7      8      ?      D      E      M      Z      g      t      u      �      �      �      �      �      �      �      �      �      �      �       �   !   �   "   �   #     $   
  %     &     '     (     )   !  *   "  +   -  ,   .  -   7  .   8  /   ?  0   @  1   E  2   F  3   M  4   N  5   Y  6   c  7   d  8   j  9   n  :   o  ;   u  <   v  =   }  >   ~  ?   �  @   �  A   �  B   �  C   �  D   �  E   �  F   �  G   �  H   �  I   �  J   �  K   �  L   �  M   �  N   �  O   �  P   �  Q   �  R   �  S   �  T   �  U   �  V   �  W     X      Y   $  Z   %  [   0  \   1  ]   9  ^   =  _   >  `   G  a   L  b   M  c   V  d   [  e   \  f   k  g   t  h   u  i   �  j   �  k   3Y2�  YYB�  YB�  YB�  YB�  YY8;�  V�  9�  Y8;�  V�  9�	  Y8P�  R�  R�  Q;�
  V�  9�  YY;�  VNOY;�  �  YY0�  PQX=V�  �  PQT�  P�  RR�  Q�  �  PQT�  P�  RR�  Q�  �  PQT�  P�	  RR�  QY�  �  PQT�  P�
  RR�  Q�  �  PQT�  P�  RR�  QYY0�  P�  V�  QX=V�  &�  PQT�  PQ�  PQT�  PQ�  �  V�  �  P�  PQT�  PQQY�  &P�  PQT�  PQ�  PQT�  PQQ�  �  V�  �  PQYY0�  P�  V�  QX=V�  ;�  V�  T�  PQY�  &�  �  PQT�  PQV�  �  T�  �  �  �  T�  �  �  �  T�
  �
  Y�  �  T�  P�  RR�  QY�  �  �  Y�  �  T�  P�  RR�  QY�  �  T�  �>  P�  QY�  �  L�  M�  Y�  �  P�  QY�  �  P�  R�  QYY0�  P�  V�  QX=V�  ;�  V�  �  L�  MY�  &�  �  V�  �  �  Y�  �  T�   PQY�  �  T�!  P�  QY�  �  P�  R�  QYY0�  PQX=V�  )�  �  T�"  PQV�  �  P�  QYY0�  P�#  V�  QX=V�  &�  �  V�  �  L�  MT�  �#  Y�  �  �#  YY0�	  P�#  V�  QX=V�  &�  �  V�  �  L�  MT�  �#  Y�  �  �#  YY0�  P�#  V�  QX=V�  &�  �  V�  �  L�  MT�
  �#  Y�  �
  �#  YY0�$  PQX=V�  &P�  PQT�  PQ�  PQT�  PQQ�  �  V�  �  PQY�  �  P�  PQT�  PQQYY0�%  PQX=V�  �  PQYY0�&  P�  QX=V�  �  P�  QYY0�'  P�  QX=V�  �  P�  QYY0�(  P�)  V�  R�  V�  QX=V�  �  P�  R�)  R�  QYY0�*  P�)  V�  QX=V�  �  P�  R�)  QY`       [gd_resource type="Environment" load_steps=2 format=2]

[sub_resource type="ProceduralSky" id=1]

[resource]
background_mode = 2
background_sky = SubResource( 1 )
             GDST,  ,          .>  PNG �PNG

   IHDR  ,  ,   y}�u   sRGB ���    IDATx��y�Uտ�S�=�Lf2YIk $�a�� Y��w����"������B� ���+
f$AeY��J2I&3���]u~T�Lo�3��{߇O���꺷���u����`0��`0��`0��`0��`0��`0��`0��`0��`0��`0��`0��`0��`0�!�u����=�����-�fnj�������!`�?��3�Q%C�`��9���ߵ��D���4-��Ѻ�p�Z�и�^|zF�f�-F���E�V�m���K=�`����R��>-3�����<�]9�`�����d����j5$���N��t���$hbE�U��Z	l�\���5M��1V�p��mцƀ`�
vhյ5���NV�j-V4-Ɏ��h�J\w�",�q�y;�w�9,Xa��B$��
	V_0��ܴxnF�o�<��*0��Nds�{(]�J��j��0	x�n_О�� ���'˪w��_G�2_�F���I�	�	��U�A�/��~����oYn�F���
���^���x�D�"��\�E?p����L�� �����Ȣi�ܔ�?.]m%XZ�����\�����U%�h��i]�����5]uʨ���y����̿����;ȞJ̻�88;$T��(·+��@soeY��2UMv�N�T�+�N`� p?�<����<���-Y^��h0ca�!�b����!X�]�o1xֈT�~�G�/#���J�,�"C���Va\EZZ�S��S<lXr/p��V�gt��{�K����[������a�� �#�q[�S���n��Ϩ,g���孡*��OUn�a|�|�7�m���~�藴����Iz-9�V��m��V\sf૮+o���>Ԧ��a ��x��<����+'�ǁC�TL-�'\WV���n&G�k]E�����<�,�� ��t�}߲��A�쟉:���U�Rs�0�Y|9CE��Wp�8�{�Y�;��_�`�!	D�ݖ�>hY���9�:cL�l`���f�鳲��YW��D8�U�,�o�
J���|W^�'����U�c+O	���g���,v�z�����z�(SQ�D�.k����D�`L6�6�#XyL���sT�8�+�+����-�u���(d�E�C?�u�q<&�'�1���t�pA��2�$�� ��̗����oH��<��[z�@�j�P��u!�*]xk|F��`Y�6p< Q�o�P����<�V��Hrje!\�P�Y���"~�:����"-���������6�b_T>��[�	;�۞�䊋e[�.�;�/�܂��]�C�D��
�e������`ca�.�7A0���!�Q;R�,7u�#2�k���*r�h��T�Q%j1�F���I~��F��tP�ȸ+���t?E��6$�V�!���G��ȍ�ykDp}�[X�X��>��[WF�����34B��!:
ճ��� ��7&o^�kP�Gi��|����Fd�-��/D��t�E~X��$��3$^���Ɠ"�T�K��8͵����۟�+���Z�'o^ڗ��&� �
��C��_hH��<C��{�9�3D���!��C��=�X:p�=���!9F����Pv䍅U�n��{r��|#~���-dG�k`H��<�M`a���b,�<�V�!����4�V1�Z��<�V�a����쨝hWC��L�0�1���ϖ\W�DP�pCc+�q��Q�ؕ�?�W��IC�1W'O8k٣�;�-��Q͏h���Y���-�C3�j~`,�<`Q��6AЁ�6�f%��)�!CQb;:,[��j�1Nw`Ѳ��g.�&�o���<��.�#�큇�"���^�!
�^�y�k(yׂ����̀��{��(�&��[W!I��#t�5s�T�j\u���baYソ��E��C`bZ
6��V����ЩjōH�����Rꢥ1B��t-�/���r����KW���L�%DϾܔ��nQ�-�q�C��7��![�@�3��Db�CY���;�v�F�D��<W�i�B�dk�-�aY���AD+Һ
�����Xr���\�tU�XAU�,-[�*�Z�g M�!�T�v��_��~#��b'�ϮmE*c�S!V���jZR��U���`��~�D��<�buC�u����?�P�H#ިIDk�eY?!CS�F�ۊ|xd0�
3�hE�8�w�i�!#��*���Db�}ѥ���,����3��(������u�yG�����/r�,�����߉�Q��|"o~U� ?@��)��!���R����bc�'zq-\�
��X� ��*>���ɢr-pk"����J��*I���������mDo~��w�ċU�j��]�4�C?"01$Z��U��T�ɐ����H�*V�ԕ~Ӣ��-+z�U��e��h�Z>�:�XF����KW�D�Ջ��e�oz�D�GսX%X�Ex6;&5L0�\�����j�{��Z��@B��v480��my�W-���B�u"�@��L���+�Lh��tD�dkA����.��lAV��$�G�����H��x�r��צ(�r��)�����!/��q,��P)V@B��(�:�Q�f�a�׎���)V^��
M��GJB�-]ٟg*�;��m�~���9P�!�p; ^�T��1V�f�ʟ�CS8C���^���rUz�@��VV-�5�+ܚO�6�9� �-�~����,�������Y7��������7��?�������q���'tOH�'x3�
�N�O����RDq��|H��S� SS,��do���P@k�G×�XB'�a�9M-�W�+�}�"�7�zX�DR,�&�_aĪ���"��X6����>��AE�#u�8�^�J$V�@Qg�[�tU��.��%���>���Q�.V�/5��I[Y�<C�D�c�m�pE �Y��y�O��i*nF���:�X���_��4�m�p�ҕ(�=�&�<<_�?����.��*x����r�ǳep�+(�1��?�[I7�����ZV�x��E:|�(k�wV"!�
YS��u�e�m���Xwz*0+s��5�����y�J'�s�a�>��FHq���6��Z �g.+���:c�?�q?�X�^��2y�,D��F�/�lvC�X+E�t_�WHCga6ߍ�g(�W᧐X��d�(�J�bSv@�h]����E��D�,��pE%X�y#én��Y�r��9����Y���Q�k*��aӰh��o]�J�����R�xz�ZC1 k��A��(�R���5,
k���f��sv��#V��Gg�.ZV�o)��aQx-@QE4��r.*&`�P*\&����
���OӰ�����$B�NH�X��B��6`&�D��m	��iX4V���N��+C�1�(*�*LQ�Hf N�"��RD?�:'�f[�m|c
(�
�	�����a0�1bY��Բ��X�*L>�z=f���0C`I�+�n
_�Ċ\��\W�`�T��V�K�S���F-��ܑ�y���cq�S\%�:�/X�|	X��J9�m�iÊ��,�v�l�˲�SP"9c�xTD?����S�:E!X!����8�dCɡ���c�,��C�P)
����&���M�����U�{�zW���.|�jZ27j�u��������4�����v��X�Z�����@V$�#���(*��:C�џ��kbiQ�2DR4g�p��� ԫ�+S�_+�!klͱ�JLt��"�ʾh,��e����m�gsQ'�![��Ehb⭊E���+/Cl�E��w�>C��x �"BT^�b�h��a޺:V���Qy84�22ě�1@Gl�QUhZ\\s���k(��(8ډ�~�/753�N@�
�!�@Z��&VP�����'V��/�>C��x6�"���vEJ�5	�,\�2V���"F9'�2��C��xzE}�h�̒K�
��[F'�w�zq)(��Z��ل�@K���Gyy�
�R��c�H��m�r/1�,C�KD�E"|VZ":�Z���=}@�,��j�g�^C�(r���.E�ں�",���O@�-��%%�X�J�]4:;	�(x��(jV$��	Nw�����$����}�VQ[ᣦ�G �t����uw�'�U,
*�6S�V1����2�-t���`Kk7-���b<��7�f?�X,�	�)V|�����Żjd����o=c���WUykg'/lle�ͼ��#�5-|�Pü9f�_�$����7��ĺ]<�V'ު1d���� ~'��S����9�N�}GO��ҟ�1����o���?��U"nב#�������q��ڔ���;��/l�����LoGB����ca� 9�O�����*�!�j��9��f�~��l�ՙ�J	���Θ��}ƌ�8u�~>r���s����[�xe�yA䀢w��u�~�z�\9��Q�U$�����͹�N--�9	g�?�б��H�*�\��P�r��V������,2����~�N8�1#�����;���(���S��s��s��og��A����ǲO}eF�oH��,1iL���1Li��xY�gM�E3�9J Xr��:r���5yL%���h&�Ud�,���,PW��EcMy��<���|򔃲V^�p�3ﰉY+����o^x$5��̯�a�j��#n:��������k_ewK��mTWW1�����ۏ���a���%=���˫���u;Gq��{�y����ƍy�'ٸi�[Z��좡�����̚9��N>�1c�����PŒ3�?�l��V�Yx�dN:xܰ�_�~=w��g<��3���q?w��S��o?>��qʩ�Ot�CxyK{�#�{!Q_Uƕ��ͨ��^�8���l�8��o��!,���O�?�I<px��O<����Ob�+�G\w��s]�lr��n����*����M�A��9�����e˾Ö-[�a��ݳg�?�8�=���>�����}�}6u~���%����O��a��%�l۶m\w������سgϐ�RU�l�>Hkk+�g�ƶ���3��a�K���d���c �d^���̕�gV9����
]hmm�ꫮ���:,��e�ڵ\��+x���~>��IY�����*�PW�/K=���Tr���~��^z��?s���ڈ���<p�\s�b��چ�L����1�3e#X�o[�o7ooo/7��֬Y3��hkk��k����_����c��팆�����g��+�pϧ��=�z�컹�3�\uF�>o�Ԅao��&�_wð��d���+\w�u���]�c���P(��V�8���aYW���o��k�"�
�������&��͘��i��I��C��C�S����ۜr�~��ٜ1sRF���sgL���������a��pX��Mn���!����s�c�R�!#Xb����O>�$�?������������u�~�����0GL�窅�&C�mq��C9|j��?j���/��z7;v��wtժ�<���C�7�koH#X��}�~�.w��g)���f�ƍqۏ���N�����5�UK�O�������w޼y3˗7��,���+i�-���6d�l���0��l� �^�6l�H�����C�m��b������s���͜2&�������q2�3쭷��_J�ϸ�r�OdH#X`8�o�|�Ɍ��<�mj��5֔�h�� ���?�!��󩧞Jk���Mk�f#X�!I�0�~�������ٺukԶ���fNS0�tʎ�d�l�ʶm��|~׮��XX��V�����ر#���-��oՀhK�/��޹3�kss��T��TLv�0��7y�gWWWںۓ�Ҳ;j�u��R�U���=�L���Mwww�}���a+t�%w�g�G:�-�{�zJ�o���ֲ�?:]}9L�\��� ;�&����˩��|^�q�щ���W!�3�3�Y[[Kyy�΃�{����`e�-�ݸC��&O���zL�]�����ol�Z�4)3��e$Ϸ��;mɛ���0��zo�H>��	'���:x�L�0>jۚ��S����N�9M�0����?�e�x�I?_��N_�L	�	�`e�6�&�|Μ�3Z��'����שItN�m�8~1���������]�3g��#�H�����������}oQ6S6�������m�w�>�T9��#�1cF�}-����������$o�]��˒�<�*]|��G7���-����}n���\p�i/GD���O%�g��=l,B_a�`+�����S�v�ai��O?�}�Q�v���蚡��G�l���7jۇ?�!:(��p\����9kf�}~�t��sC�0��A�~���lJ�ϸ�Os��ǧ�����~���C?��[2��7��_<�vԶ��
n��ש�OO��N<�O}�I�yac+Ͼ����R�V����uI{�,���7��揪��S����}�	����gS+������΋��N�8���C�.4����_�)i�ho�ᶕ�FU�ah�`e�ͻ��}U�����믿��>sوJE������;ngڴ�����[��ZIL=���ZKkg_��)S������O?}��ª�*���r���/�Ŀm�:���J��a���{i�=�%�>"��_į~}/\p��M���2�̙�?��n������}A��?�&ηS̴v����_�'=\����/|�F~|�m�t�I��ɳV���s�E�����.�`H�{�?[��^Y������﬌�4W^�F�"�������E���˚Wְv�Zv��Ekk+�55466r��s�q�QY�8�Ro����dܟr��~���F��+�}��CՎ��˗�w8e���㮮.�{�96l�HKK�4440n�8fΚŬY3�+���m|�׳7���Á�K��>-K��3�j�P��5����>.9q�!��eqđGpđG���֮>�v�+�����+[�<��nn��|�}�f�����SN�SR/C���s�zjCI4���$�"
����_^��L�/ll�{�˚X�6�2��TX�uW����������Ǘ�{�{�Xeca��o�?{���ٟEGL��[;����'�fի�Y}�v������lx�QW_����t�r�^䴙�Ļd\��߃���/m�'ߦ�פ��F�rD{O�=���?��s���i�MVj�H^۶�������6�A�U�qylm3g=�َY��z*���f}'g̜Ȣ#&3cr�)�cwg+_m��oag{�tb�#F�r̎�=���z���[̜R����>���U���SS�#�t�9l����.�l��[ٶ'�c���3���c��cl��ŽO��t�Lt\�����/oc�J�ٯ�YSưoc��*�,���=A�t��(����W��;d� Cv0��Y�%,f�V�����8f����=�a7K��#eH�Kh0��ݝ}���9bj=s��cr�n��������+[�/�!7�2������򖶡w4RĄ5�����`(�`�����`(���`( ��7�00�e0��t�i�����`(J�Ix�q��n�^�}/��}�v��7)_��RW駡����2f�S[���\T*G��XB��z�Rx%�����dwG-����������>vw�����`i�i������rk�[]FcMyԿ5>&�z�#�	��!s[�+%ea% �J�l�ƚrk�ٯ�z�� ^�������%$h����`��[R��,j�}q�3��,J��˰R��v��J�2���1�L�8�z���CKG/��vwzb��������vQ+��8h|՞脅glu9�~kʩ��Cht��9��R����*�6S���8�

<��������6��J�͕���A-J��*�'�V̝1�O���i�s�X�X�����܃��byp��ca�	�Ϝ�+��3��)�{��GY}��� ecؕA,����#���ڸA/��2  �IDATp�}��������e������糄����jD�7�l.()����㶩�/L���8��rRCu�5�2�$����o�XSN�ޞ��/�=j
��Ĥ��~����Ev���l��4�n���Vyʁ� U����b�62M'q(Ә���ڹ�l��ÊW��Ћ[�7�_Y�KJ[W�]�බ�w��v��$�_h�����U�c7�\�؍e~�gLEY���rkR]Eո�r+������4�ȵ���	�'�} �00������k�u7�It����W\��N��N��ej�d��?�[3�"㩫�s��Z�ה��'�JS�#��"���`�3;;z��ۺ;���Z;�쎾`�����i�4�"w���`�g�h���p+vz*v���v���}�|���.�2�֔��®)��wa��)��6�p�)�q��8��������]��g���I�:ky�Y�ω�L�������6�ޓ��޺Xܑ�.�=A�W8A�KkW�`��OV�t���RAݸG����tٶ�{��k��v7����2g�����V�9zؔZ^��y$����\;J�����jy�S�c8trϽ��IQ�"�5yr�N�{~�P��Gozy],#X���;�+��Co�a[[7�ںC5$����_���ݔ���@�*���΃��)�WCMw#ۓǽ��dV����Ib�g[r0eQR���?�n��d͚���]��e��v0��V\�?��ŭj����r��5�/;5Nfa�wg�g��d���nr�ɲK��g𛼶<;M�ʆ>f������,�����4���k˧��R���9�s1]���J�8���8��V����a��m�~���*��1�}�֭ڇ�o�l�������1V�`��7>�H�ZXv��sx+�߳�(b�-��a�P^=�-/��X9ɮI.���`W��#JJ�\��ׅ���{�In�L���?~��[)P�*�Oކ�s��|⎌ђ���~����3�U´g��d~�LYXӎjᠰX!��7`���ƴ;�5�̾K��l�O��`y�U���z餫7��*v��h&|X�á��VTVU"f����v?;�N�Ok�k�JW�Kv��;(+�:�ޛ�~��f��l�ne��ªi���Ӷ`�bQ�(G�����޴���]���@$C7zw���b����,��A��fڻ$d]�(�Y�G�d���O߄��Lo`o����*�h��k����2��mT�@�7��_� ��U:TT�QU�flu�ݔW��:�|�ѧo�9wTc<��#9�_��z��"�@	%%XMW�e�b7?+��٬G2g��x7�=��؎� �=A:zt��{�t�x��i�=A1�9���1�ɇ�Uؽ��mo�a��:��Gu���^�Mmg�{;�3m^��.���k�L��,r�gM���
5~j���QS�o��0g���4 �L���~=rHI	 g�<��q���2�@^���ph���dG_/ԽB:Rk9���e�+�tw����!:���h+g�+㨪�c�Y-L�ق�7z�r�Q��䀓_6��
����g�ȅ���q�Uj��`��O`0&[f�;��oS鷙Pot���3jް��ן�Dowfo���2��k2�_ό���ﰖ�P�_�]����
& ���}>˅���t����<��r[38��nw뱔�����Ω���Ԍ�U$�]>^��T&n;��Fuo����%��3˂%,�
�Uҏli
����M��}�,��͙K��J�X�)/�F.����mq�uf��wj9���YcGu.kz���:��)۩n���\�)�'�D+�L����ۻY�jsڏۧ��x-�Ѐ�Vﭾ�j��-��s؏�-���X��W�4X�)����Z�~k����<�!k�@3�`6�WJ.����p������(A�����U����bcK'���� �=��.�ڕ>�y����qK��qVͅ�X���ܵz}Φ��u8����IS}�X��*�Έ�Iե�7�;���� �:zy����:yys�}z�{:��{ ��ە�b�i٭GP�N�`0��]��4}]aIP�o��o�����7�o�������u~6�ob�tu|��X�䉏�m��䮭]}�zu�Ϝ�{,�+N���)ks`=�����{�����=�Ƭ�����(t�e?�7��y@�
V6���E�t�+��ei6��.y�ʪ��Wk�sh�Q�������#7>D�Gߠ�7���'qX�1�����ȳ{�ݽ�o�.�YJӊ�]��\W#_(�8����@ǠL���e�_jsQ��P^����w�z_6��Ϩҕ�,j�-*�^���ϥ��U�T�����s����EoOA��ۂ>g�_���t�)��SN)ȫ�.$~��wT��(��>�alC7�N��iC}J�lK�5�����怱�L��n���� o����M���gD�VUϗ�qC��OM���i�^p� �2!���L�e�k����`�">?��� ���>#��*������Og���������2�:�-$��Z?�k��9���{���-��kd�/vt������r��OU)|'��3�����W���D�lXã�ϏZ�!���)��C�`J�J]�#+�;���O�0�X%bʘ2ϝ��G>���ݟ�9����iK�#>	:>	b��RmB	V$����D�s9�NJ�}nJ�N`d�-g2�E3F�>L����I��,85��K���0>1��g�7�k>	R������������x�I~�w'�+)漒����RWnsά��U��c�*�-(�t���*�����x���x��gd�JyDI��k�Eo�Q�n�k��f�J)!��2�۷�����
���)�#�N6�3W��g���z�h�(�T2�(y��"Z� ���9�Ѱ���u��u��ڷ~�Ǵ 5+2�AS���c�&��J#X@���������B`u��5"�Բ���(K�u�|Ð$��l�p����]c.��>�����a�`�hZ27�Xy��"�٭��R�>RʓR=�|�P3�}@7܂���d������iq�?k@����Y��0I��(�*�s\\�BTPZ�h���VM��%�Ъ:��>��7b������Os,����p��>,���{Mt�`%�iɼDb��}�k��@�YLr���yPe�5	S8Ǽj*��.'���i�hEY��~�`B�#V������+�uK�����W��9�"?f�	O��H��X��$4-�7�Xy�v�Z��%��V�V�X!�TAZX�Q W�H�+!�h�f`r�`��ŧ%��M�q�q��o ҕ���S|�8
�;A�<*���bHh�h�jh�`����qkE���n������� YMٙz�h�(V�aY?ǀ wb�Ӂ�����E+ǁ�Ʋ&�v���g/\�����V���ޖ���o�:�x�$8:���^�[X#�^��2
��u�/ؖ����q=*la���@f���0�i��h�*DH� �q�m� '��1L�h2+�8 ��' �7�T;�1U#V)`,����!k��U@�XI`�%(ޣ�,p����-��*|Hm�$H��<�糧"$ܱ0��en6�=*�K���� �>p����aK�>��5
��̋�H܈A�� x�	����@^Jw}R�ޫ�+O��u����J`���8X�-�2b5J��5J��9/��Y�M������E{�{�{,�].�_��Ļ�S&����c+r��p�߉�Ӊv����o�#מ��Z�8F��Dx4�����G#<Ɩ���Wh�F�dW�"Q��4���A�#��L�p �H�`��>�j�AD&�TU$�2�����G�6���V�Y2��{Š�X1���y=�-W��9SE��3�3���Q
�� /�>��>,b=N�HI�,K��I8��Pe#X�����HD\X�� ��T�&XV��(g(z&�o��`,��B훁�+����îM�\b�n�(��Q�@C��&�3���M�x��g.[�t?qc�q��������t����x�x`�KهU@a¨}XA`���Z�Z|��^���(nD?�&)/�ي%���N��0��E�ͼhir�Rz�7z>�5�����*�c�յ_k)g��N�7�p�ߛV�����-K^ ��NY8�D��Z8��r�+��yE��V�X�|�s%C��]��=�O��w�I��X�
-�!�@���n��/�����*V��_'ic�k�Xr���6�#Xy@Ӓ�ZpkӰ�'���=Y�e0+�����
�D��h#H��[ꂵK�f�M���X�}��z�H�$�mz~�+�x�0�b�]���v��K�F��KF�/��J4����
RsHO��Z|*�GuN0Xﳥ���D�֗_�I��A�Z_����⪶Y�mAG�l��؛��M��+R�o�p%���x���6�m���!�1���4]�p-Z����H\�U�n�������?G?�N0�O46��M㿐t��[�1ec��͠��Xʙ�c-���y���wMK�8�ԫm�|�2o&[�8o R�	ƏӾ�3u:	�Y�;�{4���ȵ�g�1�U�$|S��>����K<���G�
1��qW�X��S��2���*n�ESXb�q�Ѣu�Eg�\)��s��9�4 ƇU�$���T�~�G����R8����%�����s��C
n�D�����B�T��T�kH��B%�`�ېH�՝jOd�2��VJU��b��HŒH�?	��JH^��ȦGK�9
�t/P,'~w�N���% �����x��E�������� l���	��9&������%�;LS�AUU"�$l�7mg��H�Kl�DUR�%D5�FCb�������M��S���H�c���*0�dj��s/ps ���'��zƜm�ߦ��e����0V�gJt�d}(S�x����Q��^��R�hI��-xc?&"A�@ ��F�������tQ�U%r1&��*P$��'�CM�9�I���v�+�l/W�]�o���8��{U�i�-^"���c��$�� ��S���R4�ږ�����Ec���ےbwXP|� ?������N`Bt"����v���b9�s�m����筎��m{=I"�"E�|�(��ݚw�y��E�뾝�Wy���a}��΋\	܉�y��Q*�r'�S/�6�=�Y�8��-��aYɽ"BŖ;�UM�m�O�F��G��V�_5�ƇUX���X{qِp��P��a�|��
�R��ͷ'M]�8C�	�n�(Ъ�w����q>��̔���-[�v[���ϐ���������u��?��)�\[V�.`�)�QŦ��螖(�_�Tm�3�.􉍫�����L�^�j$��S���V�b,F�
���)�'�`��g��'�tU�#�
��7�U��?`��e���#* l�t�A4����R>p.� j#B�guiL� }"���3h��y��b7M��70���d��X�����k�%:��yË%��X|�[�^���<�4̪'B���4b�S���QҐK��U\l��y�K� ���p�b�X�b-�r���q	�8vE�>�ӃA�Bq�8?�:��/ZG����&�z�$����8݋;�����K1�4r��k?���JD$�h��g~An� Ϡ<��P��|}~|}��w
#XNX�"���t�2H8f)G�,����H�Рac�g\�˛�|A\�i�'��pF��#XED�Aݍ�o�`e��ɢr��l~\�'0�e,p�{A��m��骷*����I��)&�ӽ�i^��D���}ȔI�����j�kŵ։�;�h�cW�%<U2ض�S�C&�Z�r���,�ي�"s/̾��
l��(�ͤS���"��8݋��(?.���-�HE��EU��`_ܮ^P���L�'U���2��*����ʀh���*1���%H�L`��d��<�[���!M�X�wd7�r�*w�:�C����
@��0�H�2.F������nQ���mm�����^�Vy��c� �IX$4?:���κ�]���T�
�f�Z����Io�M�i�XXEF�X�^�g+�E�������,�tX��^Ԡe�(��*>��UD�,��,;QP�#���>�ܧ��l���A��~�qg�m�C�1�Ud�<|cز $`�����Tf�f�K]}�Z�W ����,Ɲ�͜T̐�`!mEdE+�� ��
?�a�k���Oh(�_�hտׄ1fhN1/V Oh�9�4����{<�R/K(ǽ4�t1c,�"��/�4F� 4ןضW�,�
ǯգ"� z�� ��"*��aK��\�,F�`1�xM�X��:�-uV�[�s�_���ǵ��O�H�<g��5�|�d/V�`9����� ���Xr�z���'G�
������:n(��/4"1�h5�k73F�J�ݿ�N�,⋚`B������2W�E�Cz������G��(�\,V��"'�Q�F	@���^��*!Z��Y[	�
��~Q���Y��z��~���j��.s�V�OP���U�
��#V� .4VU���>Ch���͆�`SZ��>`*����v��Vb��$�xbkĪ�0CsJ�1{ͦ���aX�[�2�����$W�u�1TJ��e1�	�b�.�9�51F�����$�V+d�t��o�B 5�S�b����n@�l� G��x������g'��KMHC�b���i�P%i&d@(�g��)1(��RPƀW׮ۼ��4�#X��H�E��:e���0��^dt��{t���R�Գ�ҹ�w�b��Ö��x0V�P�?`.P;�/��7�MZQ��GR�z;�
�Й�Z�#X�H d�����@��C=�Q^��M�<������tUʐ��՝k�-����A�5���I���s���նv��[|SnjdH;��*r� *�.V ǩ�����uE��V��� g[�'}�H�*�e>JH�=���ڐK�`)��]����d=��e&>�H1�U�8V`�/�/֙rQ�(��uE��VakY�r4�ci����*�u0d#X�M��X�HmZs]C�0�U�X=
��
L�mm����
�� �o�(��"����b���sS�,��-����GrʌpF���x�ՏQ��$������!����ED�g�S���~?݃��n��/��&W~;㿻!{��	M0��^���b���CY��/���H�

#XELx6dq��}���9�V�f�@���7]�=	)�n�|"�o'���Vqc�H�+��Bo���e�?@0�ǈV�c|XEFٵ�L���?�{>4_��M���Ul�*B���oI�U�H��_g&�(F������o���E4�)%~Ɖa��6Uq�}�����5�r��`0��`0��`0��`0��`0��`0��`0��`0��`0��`0��`0��`0��`0�������c�@��c    IEND�B`�      [remap]

importer="texture"
type="StreamTexture"
path="res://.import/icon.png-487276ed1e3a0c39cad0279d744ee560.stex"
metadata={
"vram_texture": false
}

[deps]

source_file="res://icon.png"
dest_files=[ "res://.import/icon.png-487276ed1e3a0c39cad0279d744ee560.stex" ]

[params]

compress/mode=0
compress/lossy_quality=0.7
compress/hdr_mode=0
compress/bptc_ldr=0
compress/normal_map=0
flags/repeat=0
flags/filter=true
flags/mipmaps=false
flags/anisotropic=false
flags/srgb=2
process/fix_alpha_border=true
process/premult_alpha=false
process/HDR_as_SRGB=false
process/invert_color=false
stream=false
size_limit=0
detect_3d=true
svg/scale=1.0
GDST,  ,          �A  PNG �PNG

   IHDR  ,  ,   y}�u   sRGB ���    IDATx���w�ř����I���*"�P@�H��٘d���q ����|6F$����&���������DF 	P�,���6�I�]�?ffwҦ��S�׫_����~��*P(
�B�P(
�B�P(
�B�P(
�B�P(
�B�P(
�B�P(
�B�P(
�B�P(
�B�P(
�B�P(
�B�P(
�B�P(
�B�P(Q�L�H/g-[���a�ٶr��t��/�X���3b��~��0G�%(��s.{!f����Y��������{.L�m�q��_����=\�\��9f͝��6EfQ��������m��eL�Z;B�p��y�%)�2>g.{�W����gŊ�w/N���L{�9��xE(����N���o�l�L�tZx�������Ӯ��"�D^��q�AyX9L�z��`y|宀@�;R��E���˭��f��"��U�.J��1\p==f��i� �}�k��]Cz=�����'b!���x�����<��{VPX4=��.��X/kppN��~��Y -��nɤgM��ugu���N;�V�2_^.��S��#D;���
��+oS��\ByX9��e��l�m�V"K ��� z<�8��.���_bF?�x�<��nxV!����;>7�L����¦��]󴦖8]�x����-���]�o��.�,� �����4�ǜk��7�(�ԣ<�,��^ ���dC�M	zķ���TI��b���h���6����6pQ:(�m�k ��G� ⸚
�q�w�6)��s�@[���l�:��z�zGfZG��<�,���"����g.X�}
Ƞ� 5�E1p%�/	��@lm��HӲNޅ�gBhcX�45uY��_�i���i�6�:{N�R�
���`�D��A��=���n�,Z�Zr~�*RI�?��.�S�"�b�!���G����#�IL� �.�r]��J7�utt}9�T�B�8pM�!�Q�*�|q�i/�EfPVq�+ѵ@)�$2� ���ۧ|]���$��w�R�yxV��jIr���W�F���yZ������� ��%%O��=������4MV-U�ق��
�X��o�L�Oz�机[h��+ �}��6�X=B�҄������c�OIB#4��s�n�Oz�cC�X)�%XYH�:�����pl���� ��~��8�4�z���,Z�1QB�z`	!�%������������-N��o��J��%XYJP�*t�wt��*�>E��.��uQL��� u�t�Dӵ{җ*B�}J��:�;@���E	VcZ�!N�H�Bԙ�o�V�4��V�sۡz���~^ ���	O%B�b�f��4�+���d�:�wu4W���
)Mt4���ݔ'60�抁Q����]�{�d�|"kH��C����t̙}�S	�v����9�!�_F06�����6���x�lE	V���vt���
,��G�/�5�-\X���6�5�M��KR����ֺnC	W���H���g*qS�ݞ�'��[{�-^�C����5�9��g��
 _��:g�kjr�N���G��]�1�c3aKr30���poO�񶾒�p�b�m� >@�<�a�`z��������&T�0ː��%*�Ŝ�ß
����<�t��w���Oe^�@"����"�PE�l#v0��lxo��c���Dׂ/����S#��q�A��$��8R�f;J����Ά��b�iY���o&���Q:^�{ ?p4�~�OX&-)��5���>,����r�`e?Y�i��+!y�$`���I0�X�����u�퓂O���DP��Y��,C31D�Hg��0���X�	��
b*"|�>��27��bH(��25�̵��nTvV�s�ɿ/�6(F	V�1�6f �C�S$��Θk�9�(�E	V��ݭ!��M���~�WdJ��)c$�BIV:�R*o6�Q��ُ��u��%XY��i��
�3mK��5�Uς)����N��M3eK�{��\E��*G�������^숩Z|!�J�A�����=D��w�i^��t[�����dD���30�����EyX)F����6M!V{��AyX�a\�$�Ì��̭�՟��i�i���?���I7@ы4��n���kDVز�>b}�V$=�L=��F�{X�=(�߇����Ytߋ�Kw��mE�EA,���>i	+�"t������{O�ݻDY��Y��1���X�����x�*� �m��n�|pW�z~��%��
��U�u�\��g _����܄R$�%�+�q3�a��FÆ��j�F��ڝ��m]�"R�L#�%K�9�����[�;�v.Q��������@��D+$V�'XV�𚫆�/^��?��Qd�iX�R�z�)w
!���*R�OJ�`YÆzB��]s����%C��GzI�
���PP�i�Yz���'
R�f��0�� ��ˀU���H�*$Xo����]���� �o��'�r�1m�YR���?�E`mb �`��/����8B�^�8�{��ab���{�Ŕ`���o�O�Ɨ�'Z�B��R�5����'u�͂H�*Z��������|���Ң����"�� ~ 4�V�3��"�Ҳ�?���ޛ+_gdL��\s�~�iE����a^�|�fw�b���{�O����l�ma���`���g5�?I�u�R���n^�ϻ*vDj��[��X�?�v�G{Z'9mOD�d��AJ���g��9ܳ�v�Dg/+bU���xE}�I�W#����81�˲>�_<��`�3�/_E��zףD�<���"��IXmIy+�1\���Ό�û?�7Ǹ&$Z��i�r fLEVⵤ��Ub�!�ػ�w��Ή �GxZA���k����0���]�-V USN�~��~~�LXC�&�҃� ��k�9�a�Jn�t!6�S�T��xh��A�AOZ �OӴ_��*�pjB���������b�R���?F�S�&�ӿX8�6�3;;�� �b���
��Z���[ ��A�iM�>��ou�8�OJ�K��H�b��i�I�`4+XzZ��e�O!f&�E6 ������-V&�]޽ǇyY�������y�?�ă�)'��������w�{�Z��/�Z@�h遇gm`���#a��m�o�5�9��G�*(Z�Յ�0P�h~YE�)���+iz�t'���>�

��B�~%3���.��G2\� ںM�ߛ�}�HhZ�@ߍ�����+ ��f{VJ�/�� ���D��.��Pb�O��B{JC��*�%�X�����xF�g+ �8A��O�
�����_�
��ѻ�i}_��$&�eY�]���`Ŗ`���o5��$���2,��8p#��o�*-P��mM�~DT��H�R�pO<��(�X�`/�\ o���!X�+Z����3� �RʍҲn6 D�'M�
3,���,�%�3�����;�8)II�o]	<�YU�k�`U�v��K�Z���h�P�\�+&\��Ϊ�@Y
M0[:|��*��!���*$���v�߬.w�Dj��;[���[!$Tz�����b�Xs�����򻃢% �f/GӴ*௤V� ��r�7S��"B|��ܑ��TYU��Y�˲Z����W��}�=�����n\�uв�c3`�B�t�X˲	�A�X���B^	�yĎW&Z7�~Uz-R(RK��7B|�*�;���`H��,A,�{��i?ˠY
E��5�g��Z��,���G�7������A�h=��Fo�Pd=���)~w��+���߿4C�%�����6t��*�R�=�9~w�O���U�w$���\.�%�tꟲߜA���a/.�Y:�O�n��˕A��K�	/_�۹���G8��ʁ-1!C�)�G��l���D����~��Q����B�n����O����b�����+�*D^����Hs�Ns����@q߬�\��֣ߏ\&/+��@¡�0y�7�bh��B8�E�B��K-%K��UPQ�!�HɒLۑlr^�4M�/Ś&nϴM
E6�i���;����:9����h_�~[m��%C�(YC���[�Dސ�V�/%;3m�B�I����3mG��+�*3ݔ���w�k���P���Z���)3�k�����P�oz��1ɔ=
E&	>�/���9K^V4��dC�mQ(ҋl �߁�#�k���!�9����0���O�*

����0�m�hъ~Wr����5�F���a�_��Q(�I�Y.�ns`�ɠE�'�3��}���ر%�祥�N�
�f�.�"M45o�88
P~l�x~>�ݕS升�!;����Q�a|=#F)i"������"V�G�����x�4Z̴-
E*>�����&o��!������n�F'�K�+תy����=�l[ x���u�>�ݿ������V�XY&X&���Y�;��)I���}�2�Xf|�����Xx}��3f�n+���돥�$�"�X��e����1;􀧵f��4[�z���Z�tq��&�V��Si7J�H"�g��u{E�>�μ+�S+��e��?(V��Ml�e�0�bH�N�<	��.����w��;s?@�?r~x��.V� �\?��K�4M�.���_O��n��H$��"B��,�Xs�U�bup�K!�
�AZ�Ҍ�P$�%�����zû/p���t���"��+�s�����P1����.b�����2Cf)�!Yz~��o]�!��G^�a�3��%17��i��L�3�%&TS�S^dǔ��M�^Z�x���'Q�ˮSWUDm���b�t��tx�h顥ۗic�,kѕ��/��+2dQz)�:�lG�s�*Xpl-�M�elE���YR�����w6�֎&���8G�b\e�[�i�j�]W�&��f7vxX����;���Ўi�1!3M�xX ����ޔQˮk\v�x�;u�ŉ��oih��w��!�+\G��
n8�f�ņ��xg� ~�J�uC'��UE�����?�/�ỳ��P�]W�O��$kw4����ߒWs������p�1,8vd�uT;��c��I���x��#I�P1�`��M�;�`������Z�M��/~ȫ��	������qؒ׶4���m����cj��ʏ���
%Xi�����/�Ìq�)9�æ���YL�-ቷv#��E���S����)��X8su�E���4we_�|���a�BM���n^��*� >{�d��xFJ��f��x�M�X��1���n5�*�8](�J���/�è2g�Ҽ��q\5ob�����7�O���F�9���s�Z�T�*���\0c؞UGGk�Z��m�hjj������2jkj�4y2g�q:�&M�_=���t�aw�H���O���3�q�����7�b�޽457���Imm5��̚5�N��|��kƸr�s��?�m$�+���s��U��{�ny�Qֽ���?@��f��)|�K_�sΉ{�&K.�ɗy����|��ac��3��z��W��O�g���}۷�>����u�SO=��|�+L�:uH�/�9�u��yE��=���i���i���JϦk�}�l�\�A����<���Ɋ���~�j����x��WY�~��ϣ��4��]ǒ����%��\��&3Ju�}���,��v�~�i���RJ��?�ߟ�;�mm̟?M��7mt)���V
[;���!l�v�]�O�,�lC�Sȥ'�c\eѠǵ���[�ǳ}�~3�֭[���o�iӦ����7���T�u���NF�;���y��K\q҄��6}���o�[�n�y-��ٿ>�-�~ː�n\e������BD	V�Є��S&z���e�m��i�����ڸ�֥�ܹ3f�ˮs���V�O�-���f�o��_[�_[���y�_6�ɵ%)M���q�c;w�d��ۇ$6�i�f�.���;�ן2y�b�bd(�J��ʩ�W�b�
��*PF����;尿=����G%%�x,�5�_}a��!.��93F���hV�N�����v��n��������v~��'�WU�`v]jCW
%X)�i�wy���Y��夦����c��Y?��Ŕx:��*�����g�5������7SkK�voz���illLjZ�W�᝷�����{Eb(�Jyh-���II��?���i����q�YǠk��tMp�Y���xyڿ?�?�|��x��G�g��+G	V
�,v0�j�������ݻv�$}�4y�o��l�5>�N��6�sΪ��ԕ�H��q�2v����o�1������[��G	V
�D� �z�͔���[kc�M�]á���p�PS��h�xyz�ͷ��F���wuU�)��PQ����u}�ݍ)�����<x0b[�cn��J�1�InA������b�l6lxw�c����`��"��Ş#GR}�HD|!.��W#6
AL8Cz���i�P%X)��R��v�ӓ���Z��#�-��.?������<�����Ac�{��+����M��ݝdp�r��<�M:��k�d���3�tx�_T䢸8����5�}��+��St�SAii)N����=��P���܃ΰ2n\����;6b}sw��L7�y;6��5Ӓ4�ٌR���3,6���)���R�L���ѣ#����5�if��<�=�)S��4�����mj���+E��9p��g������oIɺݩ��N7�v7�T��qfz�m4��{E�(�Jkw6�֬Y�p���t:����ض����?%�e��?fN�O�Ӄ�1%�ܹ'0s�����+G	V�hl��� ��}�Ư�$���������l�[�$�l :o���\}��)I��_��}����vU�*�`���^�5`���ٳ��3�$5�iӦ��BĶ�Mݬڒܑ��U[��Y���/|�iӒ���3���Y�g��_��ԡ+�|x��7��n���O>9)�UUUr��rE����R:lo�����7"���rq�{���LJ'�<�o�q�c��~�u$%=E|�`����؅����i��r�y�(��'�_��1c"�۸�������l�9;И1c��~�ĉ#m����qϏ�0(��7cDS�|�`���V7+^�6�,�N����n�i��B-Zȯ� &D�k~����4����o�pT�ф	��odѢ��av�...榛o����_JX��6ZU�U�Q��p֜�[z�܉�O�̞=�K.��08x������v;��v*w�yW^u%G�n���O������b�}�nX����i�I���^��}�,�56bT����g��i��FKK��������.����?�7oޠ�>�v�x?�#D�(�YsT��4���{�*qp��<����o~�����ټy3[�l��������J���e�)̛?�_o��g��-�iʿ������ͽ�m��Oͦ��=�1�8�-����6lx�=�w���LgW5�����0k�,�̙3�>��x� O��'9Q�C	V��~�j;{����cVX�4�Ν�ܹs����v7���f��a7�������F~x��V��W\\��g���g��p�%���;x���&�+�<�^w��Z��_,ڸ��}rc��*��'5@$������c*�Ak��������<���}�|��w�f�D��?�"�Ȫ�6u���X�+���G:����C{�z�G;��/Yt�����8��r�1#���3���<�aڄW�������@e��&p��Q�N\�iI6hc��F�lm�H��aZ�����Z���������nW3v��p�Ο5�&Ti��[ݼ��Q�y�@�CC	V�i�����x��]L�)a����_΄�"ʋ씹�H8������6�maݮf:=F��牷v���UL�8cKO��'=F����U[�j�a�\6N�Z�IS��X]Lm���bB@��O���@k�v�vGSA�fJ������9�rtyn��{,�x&��\���me������������m��])_Q�ä�    IDAT�1-�>n�}N�P���k��mZݼ���M���P%X����@�'EJQa
�"gP��P(r%X
�"gP��P(rU�P�Bt��,�"��P��"�B���`)�������ǎ��jh�������G�'���S�>�Ev�JT�8_Y�޿*Fe��r����f�C+�)i�������������^Z�����,4�ԣ	Au�# D�jJ���Z���"G��	|�a�c��2�a�!�N�t��r��c>b1��D�Z��y#�ݾ�n�)8�z��8�ħW��T�3mjN�+A*�T;�:j���>3F�nב.5�R�PU���ѥ�PP�B��t0�!PP�DS肕�F�"�N�����{y[#��ߎ[�b���u�u�q�7s��+RJ��fE����c��9�2m���zδl��~g���
�X4k���c+�+�.q��P4ڋ��̏���D�[Qd\��֐�������w���qq�ir!ͬ�q�i�E��F�
���g6��$�4��p��UUT�:EEQf*C]v��2g����B�K�c񜱌*�kt��d�l�C�r�v�f�Kl��W���,1(9�&5j�*��9��Lc��Z��vz��|��?8��V��2'.{檍��~����6w{c�����*�k͎�M6M�����:��,z[yJc+Y�KÚ�`(���!��ҙS��I���(��ml�{�&r
���I�I���f[��J	E�S8E�I�Eu��c�U����w%+�aQ�J�̴d��%�E���o[s�W�v���*ګ,�R�U(�د�$*�ŒR4uyi�|:��"{T��3*�&��P��*sf�v�:m\5o�󶵕y�w�*Mܸ� ����F��i�,>�O�y�Ӻ}ty�?&�p�I���B�y�F�w����k(�%X��DLfxt��t���N	����\5ogL�Q����1����d�o=-��|��!��3V#���P?���xwOk��螼��Q���^)s
!�`
�S�b�z�=l���P��Cmn�N��W��RP���1n��w�#�QfZ��i���X�y���X��>wc2��h�bKC{��`q�0���wz�/�����O=�ع��3�_W��9W���U�g4�?=�:�=�^�
Q����`%�H���W�&�*��2��W�X����[����G/L���Ly�yX�gQ�a4i-h��t	k���E��V�{U�QZ����f���4�*OiZ}D21���3�M�`�Xo�;�]���&�E��s��vVcG3����.<����ppsM���H��ሤՕ�D���,3֛����r��Út�Q�95����U<�;�06�ž���BO���I&��RJ��G�/%Xq�L{�<��&�i��SSr�l��S�|��k?x��a�]�$xf���,��t#iF��2E�^)�����ҽvJ3�8L�7��8�0�.G�$�N��{"e�^�yT��< ���
�, ��nR���蚎2��Kg���t��?l��R\���E�хD#�]H�.�Oq��=�C���g�����2��fC���Qp9��8	�'�iC��Oi�.�]�I�Ah���nKMk�i:��h?ZDw����{u��pm6��e`w��6��J/�ܔ׺�m�7J�Y��po��X�5��I]�3 �@�')���'�]�`��u1g�����J���iG��`lE�}O�L���=>:=�^�N���?�^�o�۠���$q��'5RU�N�X�7�8����C�t���IJ�<T��b�V�k��Ừ����پal�vM*K씹�8l�٨*vP�Q�QY��Q�����i0�������si�#��`�b�ץۆ�Z��:E��P3���3{�젻��6%e�/������۫�hJN�i	:���l.b��Q�׺�x\�o���k�'�r���_T�+<��8���ƬO{�YF�	V�A��Hmb���	�]=��#/
�SΖ�u���1�:����TǮF1{A�t��B����ŗ&��8��H(��|\����tG��әnsW�ĴZ-�6>Qv�pQ��46�OM�X���r��~*%�N�X�F����ǴZ-)�5��0²^#�[{�0KJ�ٷ�%���so�I��}!Ix)e\Qr-����4K-W�\K�(Q^6{�K�������P!���)X��)�ӕغ�ͼ�-���~�c�ok�^I�V�%�R�Uq�5s�[�TjUA[*���V�2�����Y�;m��K[�YL������L[���V;H�)�g�Њ�ˎ7?nb_K7n�Es����ϴ��	�!����.߇�����K��B�ƒ��^ٙ�iǺ�WΛ�Ss2�V���-�v�$5��T��w�����8��a�.�4t��u{y���#��0h�����g���Y9�|���.J��@�V����F	��?���@��,	��GGy���q�U��K�6�J���ˋ�T�{������v�%XV��Z@�>�����;sCϴt�xe��C�>�y���y#�s����ƘJ�נ��8�16����GWh_O��㕝�?�4;�ԌKM��l�`+��q��qS�h���������?�b��\��/l:ģ���I��/Wm��g�x�XNp��#�{�$0P�������R�L�==3mG���$��;�����c����]�m@�B���ap���Oh�M�e��#��	��e�@���c��[x���Wٙ<s'|��+%<���|9�mn?��@#�V6�wǻ?Kk�s֐�w1Y�	U��R�!�3����*7:2�֣]�$$V��Yc��?��i�NF���ww��Ǯf���f���G��������O<4��B��i,K跙Ĳ��+ �3Pw.\�FAV4�/��W�y���i{�Cq�-���5�:]�Ŝ��\��jF��a{|����ΜZ΁vOmlbg��:)wv�0}v���4/.ʚ��!#�\�����4m��S�lXÆ�.�X�~�����Fk��9`๻���L��'���+�T��3�I���P�`ɹ�Y4}���.GByt�snT�v_��;�n������;�8,X�Ԟ�EZ�#�D�-i|+S�$��n�I��xz��d/<�������B��'�p���a���cK(��&X�i|蝦����1uv-�
Z�v���P10��
��-F���nT���+�S�U�Թ���|�'j(���$�G�Ca�-;��)����vҧ�������oTQЂ�r���X�fv|OJ��[5|��<49�`��b�z�����'=C#�<�JS�%�g���vo Z��0P4���p�Ċ*�����\�A��LB��0��q���]W1�s�=�\�����r�	&@�U�(���{A<�
��|ڒ�-Z�&X��B;m�\\�(j	�1ۋ�Ҳ�+A�TN;��w�,c�eJ���/YO�B��K,��X���Hq08�A���yt{�G�K���V��+.Z��-ΐuه�0�/�*�X0�>�+R�;���=��r����/K�,)����<>���\�����~7C�e'J��X�dQ<�@�N��L˺H�@�I P$��
iH�a!��n�0�p9w���.Z�K�όuY��8��uab���>���rsF�C�V����h�FV������8x�2Q��D�>��Z@	V?�/Y؟XaZ&�F`���}@�#��I�;O�H4YR�eJ)���i�'&�h�8WCE	� �/��?�
"����o,@ʭ�0����d��<$�L,�Y�6�7 wJ�h,�h�v�*��AX�da\����QA`=0OJ��I����ɿ&�p��`��GJy/p�#���M9.Z+�(�j0�`�U�.��}#�@%�]��vN7�����N\'�Q�,�B��ˀi^��w��-��k�1b�#̈́UKU��PP�����^ �+��ab�-���x_F����q���pݫi�j���>���~�)�L0�i�"-K>m�<w	��q�N�O<#!�2�^/+�k�b`r���\�(R���
 )M���Ϙ�u�������@+a�G*�J2Y�GӒ��4O>||��h�`�J�@yX	�����~��5@�XM�wIe�X\i���i�B|�J�M�:��K_�@��D<���jI���k�������c6U�c�� �yZ(�j$���u�\�0B����}�V�µ��`Y֍R���@q)�&�\+f>�R���7�L n�z����;tܳS��Q�����ȥ�}>����˲z����z���Ϻ���~�@������K_�@/C������'�C���i��7���Z��~gTg�z k�$V<J��D�<���u�a_z�� X\n1�u��
�}��s�n+��]zX��]�)ʣR�?Y����������i��>/k�m*�*�(�J2�n��,~`U��x����V������o�fϹ黤F�<�	CM[yXIaS�Ѻ�)�ϗ�E�O1��g�){E+�?p��w]�j;%X)�>�˺xy�^WEy�-�6{`Up�k���5�b$�k���<	�5�`�h"��Öe�V�_�Н�s�u�n����*�lx����WnW�T�F	Vm{֏�<�Ǌ �k� OL˜+��@����B�ـ
.9ח0�߅��R�-�z	��[��o
?�gFN?�cypi�A3����P�T�P��F^���|���0-�1ۂ����7KK�4���߄��צ\��J��mti�Ӗ��Є�HT�)�2��
��?as.g��}��F��`e�����1��b��d���S�*��\�tO�w�O=��7���o�B�@��	z�o�vi�+���, �E8�����C	?�zu����̵%�]��@ԁ�1�I�T���!�P[�s�&�1�=�%%��*p���/���U�	xR/�v�p�S�%XY�+�]�~��U�����ȖH�@oLI��+qvUY�*B�Jk�m�*�g;��T�x��X���� ����5�� �����$І-X��^��o�%^���&l�ߪ��%XYΪ8/������cF�O��OJ�����_#[�,i���ж�
��$Y��*;���-i��H��W���;��__Y�7�Y��)ɥ0E���.�J"�|��\�ׂi����?�dR�����6�����̉�1εRC�&J�r�Dǆh���]�fإ�a�_��bUJ��MԽ�Ud�"Y���w�GƊ�C��K�w���ؗH�]+En��r��R[bAUq^��`�Ş={8��x�3Ә2eJ`�Sw���<*r%X9�G�D"�r���6ND��]+En�+W�'4����eŜУiɭE�,��	iS�E*r%X9J����&h0͘�)'[�L����}I��+oP���e׺[IXV���;�aY������-)ͣ"7Q���$�"�M
�$b��ً�B�\�? fI˷"'QE�\%�K�$X�S����t$��)�D!ėH�/Y)�q8�|���{C���c��"Ȥ��z2EN�<�%&>ɢ;ζ�)�)bĪa���>�0����u�9ӛ���J�\�玛���CH�5�<Z�[X��E��(��Ub�e��H�I���8F����)�����e}UJYğ>(@���޲��S�����7�h|~�x!�J$�HцD,��D	s�X'a�H�2�!�_�V�e���p�<�|+���C˲:�G���RΐRV!FH)�!څ�,�0M]�u��p���� ɾ��/&�?)ٝ�/ن��X$�}���eM��U�������XE�7����}���ʨ��~��B6K�!���rBޕ�6��@	V�Y�]Ȁ�5�z,������jS`>����/&+i���+V�4�m�7
)�K$oHvk���,U��`�0�?�`�в6�:Ф����7=t�p�Xp���?�s׃h��]%d{�<�]R��!�8�w_�hMפ�I��o��O��R�,�+���aS��7f���\��+q:�,^�ao�h�!!�t�[��1�_����$�-����G���q��Yp�־�ڸ��O��WHJ�V��aӛ�ێ�2�Y��s��//��4Q�i{+9�����{p($V�߇��w�"�3�w��?�y��؊��7���!у�%Ek���&�(��;�\�H˰&��7�?o`[ً�&�`!4m��<�KvZ�q=�����5'O_�V�`y-4G��OJ�Uw����ge�Lp�'���r`Zސh��4��!�6�lH�^Z���J�rU��'H+�X��Ԉ���4]��1��_U����%ι�L��׺��#`�H�a����i"S�`�H/J�r��P��{LzF�9X�9���p؊?� ������7u�[�{�7�h#�ߤ�}(%\���<BX²ZM�x2Y����i��Ң���.������$�;����z���h�Mӗ	�,��@�
՞W����4�^�0bF|�j�"���H��R��|�z͡tK)[���n tJ��FQ�X>s���OB��`R
m���x��p�:ԝ�"e�*R�
k�Ov��]�ݜ�4&	!&iN�ս[B#)�?Ua�D��#�0��෌G�+E~�<�<��K�������>{��m�3bT�������� " u��ʻ�u���'�	U�#Ҳ�h��h&���e-!(V��!\��EU��)g͙�e��t��,Z,C�x<�wE���y�����6��F�lB���;���B�4�f�x}����W����L�L���g��U��Fڏ46�m����;g�b��z����G�ۏ4���i����#�<��~�H̾��Q�mN���:d 	>�Ῥ���>z_��� ��Du�����G����^�"���Q ��a\��;�Q�<+�e� �e5��J���a�!?vC��A�B��:�!ϰ��ω�>����V���)�&�0��]��}�bL����H���c���;��yҒ�3�!%�HK�{��k�7�yB~{�zZ��A	V2����+��vD��)M�obSg���+My/p��ݦ�y-�]�'J��1�>ПX��w���9�e=��̴�4@]��,���?�;h; �Dk��*�=_QuXyN�� �b5�@��v���:�_o��w5��Z��4�6�o�����lv��ft�x��뽇Ϋ] ���X�3J�
���z��4jz�
 +�h�,�f���]��<n�U�E��DD�*�%��~k��]W�}eQ��e�o�-��jV�6�-B� .��i1S�9�`-LO�  X^o�h�q���-
/Хi�Aj?�I�M��O�;B���Ik�W� �S�+X#Z ���8�&)�U�U@T_��H��"$V�H�2��Bғ�����`0�!��UbUX��
�џ����ۆt��,��]��?6!$��X���=��_x Ɇ(r%XyL��n��U�z��"0�M��mT�#�p�d�<|<zaiHg�GU&��x�v��`�f�cVv�����TV��w#�R=����P�Ԑ0�����4�4B�"�,~��u}��DHb��Dr�Ϟ����ByX��M��DK$�H�����F1��=����o�l��<��f�-�
�8����x�B��(�p(��L&��)���$\lH��^��L=��F	V2�4繳�5�i�&�bV�A�G�5@B=�b>خFʛ����ЗE��+��VZńq��g!Ŭl��#f�3}���Hv��"�PuXyD�O��l;p��:�89��S���u\7�k��]���gLS��ɮw�V&�.�"1ۄ5@��"�P��gX��0+��:�%�NHN�o��P�#J���'�m�[(��c�iX�L��HJ��Ӱ�l6M�oe{�0�*�P�Q�%X�M#&>D~M��/Иi3�C	V�b�-��bz��IR�;�ȭ,$�`��?�$����f+�2����xˮ"w�	%X����a�/a���y�D��M��P����#J�w���5����4Yy��5��xo��D��(+�i�K��  $IDAT� nŒ>���=�6%�_"
��`�N�0�O���<&(VL�L��&�/jl�g���ԇ��l��^c�><YLb�܇��F	V�&V 4�[ ʘQ)���B��%Z�O~W�(/�<#V �ت3bS�h6��f�m����;�̈M�ԡ+O����0\� ��D�q���+Q��y��ǈU!��oQb�P(
�B�P(
�B�P(
�B�P(
�B�P(
�B�P(
�B�P(
�B�P(
�B�P(
�B�P(
�B�P(
�B�P(
�B�P(
�B�P(
��Z6[��    IEND�B`�              [remap]

importer="texture"
type="StreamTexture"
path="res://.import/icon.svg-218a8f2b3041327d8a5756f3a245f83b.stex"
metadata={
"vram_texture": false
}

[deps]

source_file="res://icon.svg"
dest_files=[ "res://.import/icon.svg-218a8f2b3041327d8a5756f3a245f83b.stex" ]

[params]

compress/mode=0
compress/lossy_quality=0.7
compress/hdr_mode=0
compress/bptc_ldr=0
compress/normal_map=0
flags/repeat=0
flags/filter=true
flags/mipmaps=false
flags/anisotropic=false
flags/srgb=2
process/fix_alpha_border=true
process/premult_alpha=false
process/HDR_as_SRGB=false
process/invert_color=false
stream=false
size_limit=0
detect_3d=true
svg/scale=1.0
[remap]

path="res://addons/godot-voip/demo/Network.gdc"
       [remap]

path="res://addons/godot-voip/plugin.gdc"
             [remap]

path="res://addons/godot-voip/scripts/voice_instance.gdc"
             [remap]

path="res://addons/godot-voip/scripts/voice_mic.gdc"
  [remap]

path="res://addons/godot-voip/scripts/voice_orchestrator.gdc"
         �PNG

   IHDR  ,  ,   y}�u   sBIT|d�   	pHYs  �  ��+   tEXtSoftware www.inkscape.org��<    IDATx���yxT���ﹳ&��$!$V�Q6PL����hk��u���ʪh�h��-֭.���	[���(��d#�$����	J ��L�6w����L���ޙ��{�Y B!�B!�B!�B!�B!�B!�B!�B!�B!�B!�B!�B!�B!�B!�B!�B!a�� Qפ?mJ3��<.��K'W�O[f./��a,�c�~��7��Վ��Ǩv DY3�)�*�U"p%�|<�����lx��j��7�p~��k���E�8���f/X�pR����PK�F��)��~�l&� ������`���
�ס��
�0��h���0�u��5����w�5ʣ`xDa��t�GO~��3�&s.��L 	>us��r��i+�
8�Sܼ@!_�3����P�҉��
b�� �[ � ��}�\�h�ZI�Ѵ[��}�ӽ 
�6�w7,�m�26�JX�s6���	��~`�����*���;���}uBv^��b�> �%؝���\�@��`�K�O�JXah���	�] �9�����/e�M��!wy�� ^�a���[�hx���	�2�ȈV����~���e��	�*W98/X���?�!W�d�Z-6|��|�07 ���ڍ�>���-/��K �G���0 �Nt��9��j�9��˙� ��vD�2mE�vQdOoX��F�2IgQK�&?�1�`4n0Z���Z|��.�Үd��W���QGtQ��;}^�MN�S�l A� H���F�IV ��i��S�P�m��$+ �EFWF	K��hP�|���g?�R���B+��O��ڒ�V�FI�C	KÊ�r� T��S�}�_)U�5��	��R���:o�[��I(ai���,0,����,w1#_����/w9�1�]i%,�S7a��cRo����z��d�]�_L�ךt���q�D�/��j�A���Y���[,���9հ4���i�[�o}q�Yr���T�l�_"�����ך�A	K�V�U[
�e�Ǡ��U3JXG}N4�k�$�4wy�����Zeh8��.21U0fQ��1 ,-�� �(h �b��We���s�m�8����I�Y�%,�c�v�L-����
ob=�X����0D��qW�D "` �O�xs���Ip~`ju���B{!���q���43�j c  �!�Q#�,pd�*���FCr4�ڰ4��U�C�`i�R����u�S�R}9h%,��$R�jXG	K�H'�RD�G���Q��8��K'�B�6�q��4�`w��C��q��V;�f��./��z��EVQ�0;M�(�T�
��T;���}��8�L��/�0@	+0:�d���8P�Ҹi+�� �I�8�C�u��-w�5#��95cŦK|�� SԎ%�0|�M��j%,����&�c[��Ӵey8c/����y94����%a���r���[�3��S�6�~��{P�R��q~�Ł=S�)^Ý��&zڊ-�(]n8��r�.�S ;���W�.��O���o0�V���Y	�������ͨ���9y��v[��9�# �g��e/���pC	�<�ˋn��h���yc��#//O���iˋF��-�����2���/��)���Ze�;��3��yޟ8nٰ0�R��(a����橂 |���&_s..ذh����]^x?������)07�,���T{�]V8�� ��v���G�r6IUf8��`��-#X [ �o��ә�H�/�,���P�AT�����Ŧ��<Ci�]���	`s;D1�`�B-O/">aM~nSo���)�`Ƒy���h��`�"�>�e0D�? ��
�hͷ��`���yz[���y��~m�-�̀q��*J���u���b]�� �.N���+X4�@6����f� &��4r�@ۘ�-+��3�@f�����L�>\r�6�~SA�&���<�3[�{ ����G���[8��1��iˋ~��]��gle|����/_v�)Oo�f0��́ٝ.�ჱ��7�q(Dl���xD�]6p�߹��Ey9�sf�Ph37��2�gHXў�\Q���M�y�Fk,��s�(k{�`avD~�Ed�|���s��w�_������$�k�0V�r���43�,�9;}���"_ Ǻ��3�dÂ��ʰoM���5���� k;9���� �WѠ���c0�09G�4���&~#c�Q	+���$��]h�9��pu�kd��i�j���K(Z^%+�=9���vJ���5m��{ \�v�H�q\����n��PJD\�>�e0�N(>!
p��+"�=K�5��B+D�_����Y����[�v r�}²���,%D/� �ͶB�(��K©��c�{j�A�R���/����q�E�	k��uq�;j?B�EH8*u0�聜Z���n/	E��)P�"�'����j!]ְ�.�2�1|*sOcB4����	Oܮv$R��	='o��1�:%+�� ��+��n!ݝ���.���2������tuI8uYA,�\��Q�cM\t�nX�ۨv(R�Ukâ�F�xY�8�&���� �%, 07���q���"�yj!5�%�5y3�����!*��;�V�t�� `���[Ѽ�!�����`�f�㐃. f�0vR�8Qc'�>�j�!�&���ͨ���4$������n ,����V;B���V0?'_�(�� .#���Վ���=�j!7�'��Q���!rb�ߵ���jԎCn�OX �aa��`�U�� D&/�y��ED� .z pH�8��Wt7f�=�����?�[�X������h^N�ځ(%b ,�� �V�8��C��w���t5[C@8g����k���NX[� {&��~�U� 0ƍn�m ��
!!a����5Ғ�	�ڇ��� �D�Y$y���6/�\�v j�Ȅ �'���B�� $lA����ԎC-�� �	��c $���5� �X�͂�Iш�a���r8<>��;q��	�O�u!�d@fR4R㬈6`4048��wxPR�@U�K��(ai�� ��>��/ú' )��s�l���l9X�c��G}Rm����Y���ڿQ^���7'k���Y�8V�OT0R�JX*���p�\sY�L=�1�>�6�I�a�����̎�|Q�ώ��yt�� �뗂���%i�?/)ƌ��i���z��>�v����/X�%,0 ӆ��+{���sI�X���!���o�'��nV�N�b��M�A��;���(n�����Æ}�����ntWC\�	�^?�O���du���x�g#q݈��ܶúa��#:���e������"�*��GC	KAiqV<��Ḽw�,�7ܝ���A�ܴ%0���\���\�A���}���g#�-!J����Q�RH�x+���pd$ʿ���]�`� �iO�-ƀE�`ưn����e7^��8��e�f��e��/E�͢X����	}+O+/r�)V^�͂'f��J��J�WYf�S�}�P[[��>�DuUjjj���d���¸�㑕���>f�ꎃg��pe'� |\uI
����v���ؾm;�O�DuU�������d4cǍE||��^��X4} ���K�2��%�ܡ�۷K��=z���v��Ql��ϫ�����,���b����Ot��K���uOб���h3�ҿݿs�QT�o��&���_�m�Gk!ƌ����v���+����NƔ!]�a_Yб���@M}soMg�ȵ�Ո���b��e�x<X��X��Y����󎿫���u�V|��K�96���m,F�&|~T�ce���ŵ����R,Y� ��߻����p_�s���`͚5����ȑ#a0t�ʈG��R���`���т7#���jÒ�u�3�PSS��,��5��.t�����yػgo��2��bw���qV��YaT�Nez|&j��jϞ=���������_�9>��C,�����ne���A�CG	K&&��k��\.,]�0���ߩ�jkk�x�:t��c�vD�m;��+ņ�g�;���;��[w\�w�K<=���Z��#3���q��<�䡀jU��۷K/����8��0�ԕ�P͘��ծ�z�)�V��1\.�~�h�������HSw��7��U���z���d����x�g#1yPWY�6dH�����Z<��#%�@>|˞Y��vqQ&��$I��b��d2�_��۷o�֭KZnyy9����.z<.ʄ!���>ghf���7��O�!�җi��6�^�uTTH��SXX�/�����y�Ih(a�dX��E����,e�]����=~i�1�ⶫzA����n������:�:u
���� ���U�wo��M(a�")��a'�ݻ�Ɖ'd)_E�]����1SA b�&b�ޠ�x�;X�uL~�!|>y�;v�8�|���6]b-H�n� :JX2d�����e�a�'�.z,S�aA�6sP��.���L���租~*i
��L�1�r��%�D?��ծ�d�����O�n�XB���r)x!�e_X�))9��Ry;o�
�K���(a��j��e����=�˰��-0���k]Y)��Z^^��6Q��-JX2���;655Iv�ݟ���V��"G�R5�s~QG��Y����6}Hh(aɠ����7�aR��Gq���_k�^[A��4�ie9PAE��ړ�bAt���buIn=Q`yq����)9Y�N�����X��<(���k���dPR����Wzz��q�umݻ�d���{/�jj�{׮���o]����|"ǙZ���$4��d���p����[���\�z���ԔV��?ݹ1uZt�L�cJMMEϞ=e-s̘1~�~������%,��>Q����Ǐ���q�.��W��c
Gm��m������d���[߃�СCd)�b�`�53[=v��^��)���p����뮿��6�P6���o��Z�(aɤ��������w�]y8Ts��AJJ������������>���d̚=K�rc���;�n��t�u�V���d��/ڟ� (��կ__�|�O[=v��¦�wvW������걟��f��#�"so��A����?_\<�H����8V��O�oϸ��0z�hI�KLL���E�Co|r9��U��'��ێ�z�j���?�		��Pq���q����fwqv���j$��%�6�{�H����0e�N��������,RS[Of���vО�����S�'.LKK��Y���B���ƣ����,����Ý*�t���NU7�B�d�ٌ\��}w�Jc�2e2^z�%����Ĭmrc��o#b�)ੵP��n�xFF����4iR����ј7�<��G:l�a�a�T7�݆t%,��S�ww��݆1��s���|�f��᥌�l������+/ᡥ!&����n��?|����=�it�����i=\�f���G��ŗ^��qca2���"!!����?��̚=��D���Ӵ��Bt4v?x��n��S�,ƀ�L��!��pE���ǁp��Y��� �fCrr2z��Q�F!*��9�\_�_����)6���QA=g��_�h�j;kt�$���!0��>njj_~�'�QUU�Ɔ$&&�K�.4x0��X�s
���O)7�\�C
�O�܊%a�RU���
��э��du�M!���ÆUNM��}��ԇl��y���~{��6g����Ƅ	0aB�ep �����鉈���
�$T���x�����ļ�����R�duᥗ\�	���u�����҆��ɍ߽�oS�RհT���*����:�'�M���[�N�}�q,W�������"��Ǩ��Ey�rmjU.<��L��ۮ�.�������X��om?�M�JX*�;=����X��������Z�|ߖ�c��Rl>P�
���>��c�e��v�q��qr ��c�JL��iC�1 ��%��S��Ɩ����T�#�&�Q�RYE��n=��?>�Aq��G"���"31�Q&جFx|"n��8UՄ��밻��u�|s�q�$��1NU7�����n#'�OD��R��-Ez|�g%bpF<�'G�k�QfLN/����(�>Y��g�;�.�(��*t�Pϒb�X4} �g��߮�X���E}�H�.!!�S���C�|���	߯���[��q��#��W��y��:(a��-��ޒڎ7$$Dԭ�6(aB�%,BHؠ�E	��	#>f��L���EH|bD�`��E	��!a#�;���3�pY=jݨir�^�)_鬸(��H�1cp�X��RQD�%�����^��:�./�ܨjt���Fu�ՍnT7�Qiw��M	D6�I1$��H�1#�fi���jDjl����b�T+f�Et$l�A@�͂d�Y�1�=@���Zu�U-	��hpzPM~#��(�f1^�|�l�V�)1�!�Et#��V��F��QH�o{^�s��\�i����9��4����hEj�(����3��ؐӜt�%��cLH�Y`5:�Q�D�UQ�',ٿ��&2�����+� �~[�?m8����$8Q&��WH�B���VD<4�m� dH��WK����������ݑ���HV�>�j��FL�����|c�`䰦8��9�K��xQ^F�`��pJq��2@�>��:�v#\�f8*�pVZ!z�}������|��̪!���v����	�i�	Q]c�B|��E6�e2 �fAy�S��~|i�銮q���Ep��
F1�Y�Y5|�`t�y9W�x�/���>6��d��]�=��S�Z���9��ذ�k�9�ܺP�]�]�Mn�4y����3�k�*��/4�Et�z��Q�~��f������)q�k�5�K�E��vs�Q�c�L�%�ۮ썹����}	��N�[O��c��+�CD�D���Q$��ha 2X
�L�$-)6���D��f��i��Le��[V�h(�wyj܆�7�snD�y�@Q�z�S":a�L�/>���Z�qZ+�N8����f���K�-k3�l$��¶YL���N�Yjx������b��#3჈��w�·g������E[#���w ;}��R0�0�	�`֨L���)؝�w���}~W���|W��n/5M��j�F 	���bD~���E�������(�st�z��d��6�#31�_J���Zչ��C�86zv��7'h�JJy��V����Ն��n×ǥ_�#�ޓ�+��ōn���+B�����9��.�����:Zjh;a�,ʿ����K��� @�Du�zn��cXrl�9��P�ߛ���z�+�c���L�(5$��AT��wY���a0��[��!5��Յ�h;�β�lo"N~�
�[���հ��W��aEt�2�O�&���y�E�K¨D7L/Atb�*�at���$voķ�h���^��Fw5���V��'*��oK�F��~u�]
�I�Du��x.��vC�������D�� >�aE.�˝�mX��[Ò�ѽې���T}����SK`�銒o�d+��{��tD��ۤx��	K4���Sv���χ\�6���+�kTe�/aZ�jK�q�0}(�������_�R��0�h���\f���G����{�U��qi��KV:���
���$K�o�I��mX�ހ�����UѼ� ������u�h�J�]��W�B�\�?Ɩ"�W��_{�O�hR<a�ʢ�u�BhDD'��J��~-K��-хaK 0:�a�&�DL�K�װ������pe���jQD_6c� ~��%��5��l`6
p{;#�`�l�I��t5�P֊�+��Mp6��v�9���<��d�1s��7��<�%9��%Z�ډ`�l�)|�~�������іگ8�!�՘�OX��c��e�k�}gޕ�;��68��;�hpy��l���E����sc��N/<tϹdTⓥ���V  �IDATk���.���X<Ξ����ҩ��\�iGz�:$um���eB�&\2����z����i�a�a�������YL����Fp��ژʸ^�.`l��jK�',pq��W���?�+�����Ӌ
wv��Sk�<�8�����h0w~�-j-h���ľ.��u���*�T����~���M��!Ŝ�X��Q&�g�P����Y�l���b�?�b���W�L9n�G��2�|�(��N���qhWW��~L��f�<G��`��2d������{qEԏ�	��װX���.Ts"��}�]�<بd�52��S-�E��(��l�Aڙ��g[����|�&#��$i�`Ct������N&>?jNX�Ey9*T�%�V3����}sJ�iR��vw�{@!�bnBU�M�;Ru&7�܄.BR��e��k�b�}R�nDE?�ZE	�����j���y�[�K�_7w��ې�$	��q�,�6��(ܣ�<%5؄X�(f������ <\������uB�� ���ϮQ�@����V�9Q���o�� �P��O�EqU#j�<�;=p{E0�vo�w��s�݇����̌�ٰ	�9ǫEGU[v�����2affd{�� 8�}L��H6�"�Z��g\8S������{����$����ݡ^�p��-T�"��������h����
���J|���Cfk���c���(�.�����&��@���h�x�͋'n>P���5Mn���Ai�7$a�u,v8�B��)�Q��z�����`wz���jwzP��?��Qm��q��ßՎC+t0n_:S����R;�P]�^DE�+$�������[�7>9&I��ΰ���U�1eHWXMޯ{v1��=��x��Cd�P���d߯vZA5��p��3�~
 V�X�e�zZ����l��흞��bkej��mr���Ő����Ë[��È���׆�?��������Z�����AhIX��rٸdꙩ+
c�Ԏ%XI������	!�<`�EaT��J� �v�p#������N|q��U:��h弹-��D"F�.	:F HHp��,쾃��~��7���;�(a]����.?�#Ԏ%Qў�گ��Lhl����n1�{i����1 �&�ǚ0�W,N׹��U8r6�I�p9���
��7:�稏��Q��Qhuk����Fy���@x�;d1zC��d.Y1 �I�=�R;LVmɈ7cav:&�~`A���1Z�a�߲������;W�۴F	��s����Ԏ#&�R�p�'��-�/�Ǵ~���0��$��
�s��m���OT�����S;
-��Վ�E�>��C����O�8��N�,䛆'#��G�q1�c�@����g
f��vZE	ˏ�� |�v�`<��`���A��0V���1A=G��TgxolC�Cjǡe���X=w�/��r8�Վ�#,��:�'}���	��S B�E�07h6���i^^^�]�*�VV��us�g(R;B�� �ڇY���9� �!�gn����˵�>_{ (a`â�F��`�ڱ��!��G�Cy���i9aq��\�f��q�6#��������?a�ϫK[B�}�O���1�g�:�jV����Ah�s���_ x�Qj���jKaҾ��v��i������r�NS0�jX!ذ0� �
��*&�mX�w��K��QS��Ec���]�P�%�mX8q��`�U�cεa�����a~����g��ܸ8G��Pu�.	;aâ�F wNv�?E����Z���a+��jhn�
�WuG�q��Eٛ�$�QK��O�'X���`�I�t� }�0<�F�=�j���E9��$@5,��ܖ~d�ʏ�,z|��J�^
�� vmX�qc�����B^�J�.\�(aIl�}*<8cŦ7|��8��P��\�Ѡ�>���V�ϓ>��p ����WV���A	K&-���N[^4��/02.�q��h�"��%;�>����9_�_\䢄%����;\?�����N�p/�Жq����yR"�Po,0�V��㌽)����O�U�%,�l\2����+�=)z�7� >L�2BI>ᖰ4�! /q�~m���F���$�����. oxk���+D�F�1��ٯk�S�Y��W��ݰh�������/����yyy>�]=Ndl�|.�����\��`�S��sA�Չ�U�u���*�є�꣄�-s m�mΪU��Sr 6�3>�C�9r�#jX�?�l/�7r.��Ϫ�JIJ[(aiL�	���S��
��jpL���to�yT�j_پ��|���֭_��ZbD��4nâ�
4�õ r��2����F`0 c�mXaԭ���mX^ �����N�y��_8��t�Q�
3�'���_`fޚh��6�G�}��13����X����#ξF��֦��k�f�2t�H�V�k9����#c9X�	K#�j�ؑ��>���{�KQ%,� �.���GH�@���'L��-.�Y^΀�`�Lr�c��y�`�NI��G	KGB�0�MG��q���W���4��� 2� 0���`Y`|�#�Af�e;c���Z��Z��ך�=���Q�9�H��V]��P��	A��tu���Q���^>qb6�NX�c�&~ȶ�4���<�6Q��	ͬ)�P�Q)]�%,�b'P	ker  �c������BDhU�p:�C]9����E	K'h���0:��!%e!|*�����"��G��Ų�$T���B��ѝs��N�}�-���L�E	KOB�I�c߅PBG�n1Z���h[8�'~��H�?b��׻
����5���:�ch�ݠ������0�������'����1333��\�,�c�/�$JXz�c�PjLDL0�dee=
�5	"~�gϞ��&"6�Z��� ^���t�7�T����Ƙ/++�N�؝ �B�
�YYY�2Ƃ�����9�!�I4��N0�B�a��ر(�9�c<++�U�����h�������o�+��٫gϞ�1��'�Z܍�����S�.�K�\��Y��ü�x-�W�}ހ� ^�:�\8v�X��� �e���w�w��G�\���x}�Q�(�L�D;(a��g=�ܡ=���9�_Y'�KnIH�[~$�9X�N�j����4 ��$ԉ�+��!�D ���Xz�*����BĠ��Mı�+���8�%,������Xqz��m�ȣ�3ۖ� �<��b��7�%,a"�b�;��.�_�űj�9U�����=&"9���|���A�C	KG8�~��:�����¸�ԧyIj���/J�x���cD'��{�Z5�'�QV:S�u�N�0���9曓v���HT�*�/����@�N�jGڄ'�H��K�3����	��aG��?��g��.o�$�T�� ��^,`���8c�� ,�!T�ҙ���$��] J�]�r�g-F�z�UO�H��V���f�팱� �$�m�	��Ĝ<�4�#��t�b�ï�W�	�G`|��e�?-��3;���Kr�<� �9��1�K�  ��6񉻥�'Q%,*��H��!�eU;D �g�� `�p�1��^�3X룍N 4y���gK�\H�؏q6�#9�`�w���5���s�:!���J(a�T�ƥ� �S�8��^H��Ľj�A�G��:%2���� �jǢ�*̏��հt�*���U��P�E��O��vD��t�s���K���v,J�����O\ۙA�Dۨ���1nśCN?��N~%+}�V�]��(Q� lj�"����	?~j�ځyQ�>2Q��: �c���s\�|�jB�G	+��|����!q'M5q�ߘtÓ�Q%�S���W2����E��L��4�U����W-����v,!�� ޔ0�)��8�PP��;M�I)�c��>�ZN��3	U������Q;�<JX�nՃ}9�g \�vs| QX�p��G���� ��������R[VA�����!��!꣄EZ��i��������K�Ԕ���k��5ˏ��-�K?r>JX�C|U����np��:�w���pw��\��慸�"�4[�PK"�����vH>��m7��\����E'J_%��$��H��-�%%j� A��E&���Q��	�	��`P�"8]u��%B��l�痜�l�ǆ�6@��q(��О��(����`?Wf�W�.JX����Y�� �W;9p� ���y<�v,D^��t���cpT��`�ڱ��˨r���G-m:FmX:���S�u�� `�#�s#���%,��[�A)�9(a�]������:�w��[�̉tY�_T�ұƔ�T��)�
 ��6$8�v D��t������Jn29�Վ�ȇ��Y��n�A�0e���c �6,�s-_Z C�8�pҲ��,�� ���1���+��P�z�C 򢄥w���_B��i����Ayiu�"��'�b�����\t�<g~��o�~��������,����| &�㑘+���V�@���~�@����4���x��V�9�p`<>�g� �ks�L�6����ee���B!�B!�B!�B!�B!�B!�B!�B!�B!�B!�B!�B!�B!�B!�B!�B!����s���    IEND�B`�      ECFG      _global_script_classes�                    class         Network       language      GDScript      path   '   res://addons/godot-voip/demo/Network.gd       base      Node            class         VoiceInstance         language      GDScript      path   1   res://addons/godot-voip/scripts/voice_instance.gd         base      Node            class         VoiceMic      language      GDScript      path   ,   res://addons/godot-voip/scripts/voice_mic.gd      base      AudioStreamPlayer               class         VoiceOrchestrator         language      GDScript      path   5   res://addons/godot-voip/scripts/voice_orchestrator.gd         base      Node   _global_script_class_icons|               VoiceInstance                VoiceOrchestrator                VoiceMic             Network           application/config/name      
   godot-voip     application/run/main_scene0      &   res://addons/godot-voip/demo/Demo.tscn     application/boot_splash/image         res://icon.png      application/boot_splash/fullsize              application/boot_splash/bg_color      q�>q�>q�>  �?   application/config/icon         res://icon.png     audio/default_bus_layout             audio/enable_audio_input            editor_plugins/enabled0         #   res://addons/godot-voip/plugin.cfg  $   rendering/quality/driver/driver_name         GLES2   %   rendering/vram_compression/import_etc         )   rendering/environment/default_clear_color      q�>q�>q�>  �?)   rendering/environment/default_environment          res://default_env.tres        