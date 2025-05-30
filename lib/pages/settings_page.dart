          : DateFormat.yMd().add_jm().format(_selectedDateTime!)
          ),
        ),
        Row(
          children: [
            Text(AppLocalizations.of(context)!.intensity),
            Expanded(
              child: Slider(
                value: _scheduleIntensity,
                onChanged: (value) {
                  setState(() {
                    _scheduleIntensity = value;
                  });
                },
                min: 0.0,
                max: 1.0,
                divisions: 10,
                label: '${(_scheduleIntensity * 100).toInt()}%',
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text('${AppLocalizations.of(context)!.time}:'),
            SizedBox(width: 10),
            SizedBox(
              width: 60,
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.seconds,
                ),
                onChanged: (value) {
                  setState(() {
                    _scheduleDuration = int.tryParse(value) ?? 60;
                  });
                },
              ),
            ),
            Text(AppLocalizations.of(context)!.secs),
          ],
        ),
        ElevatedButton(
          onPressed: _addSchedule,
          child: Text(AppLocalizations.of(context)!.addSchedule),
        ),

        Divider(),

        Text(AppLocalizations.of(context)!.scheduledJobs),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            var sched = schedules[index];
            DateTime time = DateTime.fromMillisecondsSinceEpoch(sched['scheduleTime']);
            return ListTile(
              title: Text('${sched['deviceId']}'),
              subtitle: Text(
                '${DateFormat.yMd().add_jm().format(time)}, '
                '${AppLocalizations.of(context)!.intensity}: ${sched['intensity']}, '
                '${AppLocalizations.of(context)!.duration}: ${sched['duration']} ${AppLocalizations.of(context)!.secs}',
              ),
            );
          },
        ),
      ],
    );
  }
}
