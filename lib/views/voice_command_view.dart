import 'package:flutter/material.dart';
import 'package:voice_control/controls/notifications/notification_manager.dart';
import 'package:voice_control/database/voice_command_model.dart';
import 'package:voice_control/database/voice_commands_database.dart';

class VoiceCommandView extends StatefulWidget {
  final VoiceCommand voiceCommand;
  final VoidCallback onDelete;

  const VoiceCommandView({
    Key? key,
    required this.onDelete,
    required this.voiceCommand,
  }) : super(key: key);

  @override
  _VoiceCommandViewState createState() => _VoiceCommandViewState();
}

class _VoiceCommandViewState extends State<VoiceCommandView> {
  late TextEditingController _textEditingController;
  late String editedCommand;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.voiceCommand.command);
    editedCommand = widget.voiceCommand.command;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _showEditDialog() {
    setState(() {
      isEditing = true;
    });
  }

  void _cancelEdit() {
    setState(() {
      isEditing = false;
    });
  }

  void _saveEdit() async {
    setState(() {
      isEditing = false;
    });

    final updatedVoiceCommand = VoiceCommand(
      id: widget.voiceCommand.id,
      applicationPackageName: widget.voiceCommand.applicationPackageName,
      command: editedCommand,
      xCoord: widget.voiceCommand.xCoord,
      yCoord: widget.voiceCommand.yCoord,
      language: widget.voiceCommand.language,
    );

    await VoiceCommandsDataBase.instance.update(updatedVoiceCommand);

    NotificationManager().showNotification("Saving:", editedCommand);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showEditDialog,
      child: Container(
        margin: const EdgeInsets.fromLTRB(30, 3, 30, 3),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.brown,
            width: 3,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: IgnorePointer(
                ignoring: !isEditing,
                child: TextField(
                  controller: _textEditingController,
                  onChanged: (value) {
                    setState(() {
                      editedCommand = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.language),
                Text(
                    widget.voiceCommand.language,
                  style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black26
                  ),
                )
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              children: [
                Text(
                  "x: ${widget.voiceCommand.xCoord.toString()}",
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black26
                  ),
                ),
                Text(
                  "y: ${widget.voiceCommand.yCoord.toString()}",
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black26
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: isEditing ? _cancelEdit : _saveEdit,
              icon: isEditing ? const Icon(Icons.cancel) : const Icon(Icons.save),
            ),
            IconButton(
              onPressed: () async {
                await VoiceCommandsDataBase.instance.delete(widget.voiceCommand.id!);
                widget.onDelete();
              },
              icon: const Icon(Icons.playlist_remove_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

