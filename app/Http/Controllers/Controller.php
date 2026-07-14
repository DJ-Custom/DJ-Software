<?php

namespace App\Http\Controllers;

use App\Traits\PreventsDuplicateSubmissions;

abstract class Controller
{
    use PreventsDuplicateSubmissions;
}
