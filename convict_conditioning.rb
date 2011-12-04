progressions = {
  :bridge           => [:short, :straight, :angled, :head, :half, :full, :wall_walk_down, :wall_walk_up, :closing, :stand_to_stand],
  :handstand_pushup => [:wall_headstand, :crow_stand, :wall_handstand, :half, :full, :close, :uneven, :half_one_arm, :lever, :one_arm],
  :leg_raise        => [:knee_tuck, :flat_knee, :flat_bent, :flat_frog, :flat_straight, :hanging_knee, :hanging_bent, :hanging_frog, :hanging_partial_straight, :hanging_straight],
  :pull_up          => [:vertical, :horizontal, :jackknife, :half, :full, :close, :uneven, :half_one_arm, :assisted_one_arm, :one_arm],
  :push_up          => [:wall, :incline, :kneeling, :half, :full, :close, :uneven, :half_one_arm, :lever, :one_arm],
  :squat            => [:shoulderstand, :jackknife, :supported, :half, :full, :close, :uneven, :half_one_leg, :assisted_one_leg, :one_leg],
}

reps = {
  :bridge => {
    :short            => ['1x10', '2x25',  '3x50'],
    :straight         => ['1x10', '2x20',  '3x40'],
    :angled           => [ '1x8', '2x15',  '3x30'],
    :head             => [ '1x8', '2x15',  '2x25'],
    :half             => [ '1x8', '2x15',  '2x20'],
    :full             => [ '1x6', '2x10',  '2x15'],
    :wall_walk_down   => [ '1x3',  '2x6',  '2x10'],
    :wall_walk_up     => [ '1x2',  '2x4',   '2x8'],
    :closing          => [ '1x1',  '2x3',   '2x6'],
    :stand_to_stand   => [ '1x1',  '2x3',   '2x10-30'],
  },
  :handstand_pushup => {
    :wall_headstand   => [ '30s',   '1m',    '2m'],
    :crow_stand       => [ '10s',  '30s',    '1m'],
    :wall_handstand   => [ '30s',   '1m',    '2m'],
    :half             => [ '1x5', '2x10',  '2x20'],
    :full             => [ '1x5', '2x10',  '2x15'],
    :close            => [ '1x5',  '2x9',  '2x12'],
    :uneven           => [ '1x5',  '2x8',  '2x10'],
    :half_one_arm     => [ '1x4',  '2x6',   '2x8'],
    :lever            => [ '1x3',  '2x4',   '2x6'],
    :one_arm          => [ '1x1',  '2x2',   '1x5'],
  },
  :leg_raise => {
    :knee_tuck        => ['1x10', '2x25',  '3x40'],
    :flat_knee        => ['1x10', '2x20',  '3x35'],
    :flat_bent        => ['1x10', '2x15',  '3x30'],
    :flat_frog        => [ '1x8', '2x15',  '3x25'],
    :flat_straight    => [ '1x5', '2x10',  '2x20'],
    :hanging_knee     => [ '1x5', '2x10',  '2x15'],
    :hanging_bent     => [ '1x5', '2x10',  '2x15'],
    :hanging_frog     => [ '1x5', '2x10',  '2x15'],
    :hanging_partial_straight => [ '1x5', '2x10',  '2x15'],
    :hanging_straight => [ '1x5', '2x10',  '2x30'],

  },
  :pull_up => {
    :vertical         => ['1x10', '2x20',  '3x40'],
    :horizontal       => ['1x10', '2x20',  '3x30'],
    :jackknife        => ['1x10', '2x15',  '3x20'],
    :half             => [ '1x8', '2x11',  '2x15'],
    :full             => [ '1x5',  '2x8',  '2x10'],
    :close            => [ '1x5',  '2x8',  '2x10'],
    :uneven           => [ '1x5',  '2x7',   '2x9'],
    :half_one_arm     => [ '1x4',  '2x6',   '2x8'],
    :assisted_one_arm => [ '1x3',  '2x5',   '2x7'],
    :one_arm          => [ '1x1',  '2x3',   '2x6']
  },
  :push_up => {
    :wall             => ['1x10', '2x25',  '3x50'],
    :incline          => ['1x10', '2x20',  '3x40'],
    :kneeling         => ['1x10', '2x15',  '3x30'],
    :half             => [ '1x8', '2x12',  '2x25'],
    :full             => ['1x10', '2x10',  '2x20'],
    :close            => [ '1x5', '2x10',  '2x20'],
    :uneven           => [ '1x5', '2x10',  '2x20'],
    :half_one_arm     => [ '1x5', '2x10',  '2x20'],
    :lever            => [ '1x5', '2x10',  '2x20'],
    :one_arm          => [ '1x5', '2x10', '1x100']
  },
  :squat => {
    :shoulderstand    => ['1x10', '2x25',  '3x50'],
    :jackknife        => ['1x10', '2x20',  '3x40'],
    :supported        => ['1x10', '2x15',  '3x30'],
    :half             => [ '1x8', '2x35',  '2x50'],
    :full             => [ '1x5', '2x10',  '2x30'],
    :close            => [ '1x5', '2x10',  '2x20'],
    :uneven           => [ '1x5', '2x10',  '2x20'],
    :half_one_leg     => [ '1x5', '2x10',  '2x20'],
    :assisted_one_leg => [ '1x5', '2x10',  '2x20'],
    :one_leg          => [ '1x5', '2x10',  '2x50'],
  },
}

p progressions
p reps
